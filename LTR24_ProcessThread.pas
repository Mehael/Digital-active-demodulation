unit LTR24_ProcessThread;

interface
uses Classes, Math, SyncObjs, Graphics, Chart, Series, StdCtrls,SysUtils, ltr24api, ltrapi;
// Время, за которое будет отображаться блок (в мс)
const RECV_BLOCK_TIME          = 500;
// Дополнительный  постоянный таймаут на прием данных (в мс)
const RECV_TOUT                = 1000;


type TLTR24_ProcessThread = class(TThread)
  public
    //элементы управления для отображения результатов обработки
    visChAvg : array [0..LTR24_CHANNEL_NUM-1] of TChart;
    MilisecsToWork:  Int64;
    MilisecsProcessed:  Int64;
    phltr24: pTLTR24; //указатель на описатель модуля

    err : Integer; //код ошибки при выполнении потока сбора
    stop : Boolean; //запрос на останов (устанавливается из основного потока)
    Files : array of TextFile;
    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // признак, что есть вычесленные данные по каналам в ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
    data     : array of Double;    //обработанные данные
    ch_cnt   : Integer;  //количество разрешенных каналов
    recv_size : Integer;
    
    procedure updateData;
  protected
    procedure Execute; override;
  end;
implementation


  constructor TLTR24_ProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TLTR24_ProcessThread.Free();
  begin
      Inherited Free();
  end;

  { обновление индикаторов формы результатами последнего измерения.
   Метод должен выполняться только через Synchronize, который нужен
   для доступа к элементам VCL не из основного потока }
  procedure TLTR24_ProcessThread.updateData;
  var
    ch,i: Integer;
  begin
    if visChAvg[0].Series[0].Count = 0 then begin
      for i := 0 to recv_size-1 do begin
        visChAvg[0].Series[0].Add(0);
        visChAvg[1].Series[0].Add(0);
      end;
    end;
    
      for ch:=0 to LTR24_CHANNEL_NUM-1 do
      begin
        if ChValidData[ch] then
        begin
          for i := 0 to recv_size-1 do begin
            writeln(Files[ch], data[ch_cnt*i + ch]);
            visChAvg[ch].Series[0].YValue[i] := data[ch_cnt*i + ch];
          end;
        end;
      end;
  end;


  procedure TLTR24_ProcessThread.Execute;
  type WordArray = array[0..0] of LongWord;
  type PWordArray = ^WordArray;
  var
    stoperr,i : Integer;
    rcv_buf  : array of LongWord;  //сырые принятые слова от модуля

    ch       : Integer;

    recv_wrd_cnt : Integer;  //количество принимаемых сырых слов за раз
    recv_data_cnt : Integer; //количество обработанных слов, которые должны принять за раз
    // номера разрешенных каналов
    ch_nums  : array [0..LTR24_CHANNEL_NUM-1] of Byte;
    // временные переменные для вычисления. в конце обновляются уже поля
    // класса - ChAvg и ChDataValid
    ch_avg   : array [0..LTR24_CHANNEL_NUM-1] of Double;
    ch_valid : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
  begin
    //обнуляем переменные
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
      ChValidData[ch]:=False;
    Synchronize(updateData);

    //Проверяем, сколько и какие каналы разрешены
    ch_cnt := 0;
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
    begin
      if phltr24^.ChannelMode[ch].Enable then
      begin
        ch_nums[ch_cnt] := ch;
        ch_cnt := ch_cnt+1;
      end;
    end;

    { Определяем, сколко преобразований будет выполненно за заданное время
      => будем принимать данные блоками такого размера }
    recv_data_cnt:=  Round(phltr24^.ADCFreq*RECV_BLOCK_TIME/1000) * ch_cnt;
    { В 24-битном формате каждому отсчету соответствует два слова от модуля,
                   а в 20-битном - одно }
    if phltr24^.DataFmt = LTR24_FORMAT_24 then
      recv_wrd_cnt :=  2*recv_data_cnt
    else
      recv_wrd_cnt :=  recv_data_cnt;




    { выделяем массивы для приема данных }
    SetLength(rcv_buf, recv_wrd_cnt);
    SetLength(data, recv_data_cnt);
    err:= LTR24_Start(phltr24^);
    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        { Принимаем данные (здесь используется вариант без синхрометок, но есть
          и перегруженная функция с ними) }
        recv_size := LTR24_Recv(phltr24^, rcv_buf, recv_wrd_cnt, RECV_TOUT + RECV_BLOCK_TIME);
        MilisecsProcessed := MilisecsProcessed +  RECV_BLOCK_TIME;

        if MilisecsProcessed > MilisecsToWork then
          stop := true;

        //Значение меньше нуля соответствуют коду ошибки
        if recv_size < 0 then
          err:=recv_size
        else  if recv_size < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          err:=LTR24_ProcessData(phltr24^, rcv_buf, data, recv_size,
                                  LTR24_PROC_FLAG_CALIBR or
                                  LTR24_PROC_FLAG_VOLT or
                                  LTR24_PROC_FLAG_AFC_COR);
          if err=LTR_OK then
          begin
            for ch:=0 to LTR24_CHANNEL_NUM-1 do
            begin
              ch_avg[ch] :=  0;
              ch_valid[ch] := False;
            end;

            // получаем кол-во отсчетов на канал
            recv_size := Trunc(recv_size/ch_cnt) ;
            for ch:=0 to ch_cnt-1 do
            begin
              ChValidData[ch] := True;
            end;

            // обновляем значения элементов управления
            Synchronize(updateData);
          end;
        end;

      end; //while not stop and (err = LTR_OK) do

      { По выходу из цикла отсанавливаем сбор данных.
        Чтобы не сбросить код ошибки (если вышли по ошибке)
        результат останова сохраняем в отдельную переменную }
      stoperr:= LTR24_Stop(phltr24^);
      if err = LTR_OK then
        err:= stoperr;

    end;

      for i := 0 to recv_size-1 do begin
        visChAvg[0].Series[0].YValue[i] := 0;
        visChAvg[1].Series[0].YValue[i] := 0;
      end;

    for i := 0 to ch_cnt-1 do
      CloseFile(Files[i]);
  end;
  {
  

  }
  {
procedure TMainForm.SaveChannelsData;
var
  channel: Integer;
  i: Integer;
begin
  for i := 0 to ChannelPackageSize do begin
    chGraph.Series[0].YValue[i] := chGraph.Series[0].YValue[ChannelPackageSize+i];
    chGraph2.Series[0].YValue[i] := chGraph2.Series[0].YValue[ChannelPackageSize+i];
  end;

  for channel := 1 to ChannelsAmount do
    for i := 1 to ChannelPackageSize do begin
      writeln(Files[channel], ChannelData[channel, i]);
      if channel = SelectedChannel1 then
          chGraph.Series[0].YValue[ChannelPackageSize+i-1] := ChannelData[channel, i];
      if channel = SelectedChannel2 then
          chGraph2.Series[0].YValue[ChannelPackageSize+i-1] := ChannelData[channel, i];

    end;

    for i := 1 to ChannelPackageSize do
        writeln(Files[DEBUG_DATA], LastCalibrateSignal[1]);
end;
      }
      {
procedure TMainForm.RecalculateConfigValues;
begin
  doUseCalibration:= CheckBox1.Checked;
  SelectedChannel1:=StrToInt(Ch1.Text);
  SelectedChannel2:=StrToInt(Ch2.Text);
  MinutesWork := StrToInt(txWorkTime.Text);  // время сбора данных в минутах, минимум 1 минута!!!
  if cbTimeMetric.Text = 'часов' then
    MinutesWork := MinutesWork*60;
  if cbTimeMetric.Text = 'дней' then
    MinutesWork := MinutesWork*60*24;
  //CalibrationDelay := BlockAccseleration* 60 * StrToInt(txCalibrationDelay.Text);  //период калибровки в блоках (1 блок = 1 с)
  CyclesWork := Round((MinutesWork * 60) / (BufferSize / (1000 * (Frequency))));
end;   }

end.

