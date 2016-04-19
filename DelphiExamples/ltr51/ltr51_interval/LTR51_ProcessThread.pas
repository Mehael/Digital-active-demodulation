unit LTR51_ProcessThread;



interface
uses Classes, Math, SyncObjs,StdCtrls,SysUtils, ltr51api, ltrapi;



type TLTR51_ProcessThread = class(TThread)
  public

    phltr51: pTLTR51; //указатель на описатель модуля
    IntervalMax : Double; //максимальный измеряемый интервал
    ReqFrontCnt : LongWord; //требуемое кол-во фронтов, между которыми подсчитывается интервал
    err : Integer; //код ошибки при выполнении потока сбора
    stop : Boolean; //запрос на останов (устанавливается из основного потока)
    mmoLog : TMemo; //элемент управления для вывода сообщений



    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    cur_msg : string;
    procedure sendLogText(msg: string);
    procedure sendChMsg(ch: Integer; msg : string);
    procedure showCurMsg();
  protected
    procedure Execute; override;
  end;
implementation
  type TCH_INFO = record
      fnd_fronts: LongWord ;
      cntr : LongWord ;
  end;

  constructor TLTR51_ProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TLTR51_ProcessThread.Free();
  begin
      Inherited Free();
  end;

  { Вывод строки в лог программы.
   Метод должен выполняться только через Synchronize, который нужен
   для доступа к элементам VCL не из основного потока }
  procedure TLTR51_ProcessThread.showCurMsg;
  begin
    mmoLog.Lines.Add(cur_msg);
  end;

  procedure TLTR51_ProcessThread.sendLogText(msg: string);
  begin
    cur_msg := msg;
    Synchronize(showCurMsg);
  end;

  procedure TLTR51_ProcessThread.sendChMsg(ch: Integer; msg : string);
  begin
    sendLogText('Канал ' + IntToStr(ch+1) + ': ' + msg);
  end;


  procedure TLTR51_ProcessThread.Execute;
  var
    stoperr : Integer;             //код ошибки завершения сбора
    ch_info : array of TCH_INFO;  //информация по каналам для рассчета интервала
    i, ch: LongWord;
    rcv_buf  : array of LongWord;  //сырые принятые слова от модуля
    data     : array of LongWord;  //обработанные данные (числа n,m)
    max_cntr : LongWord;           //максимальное значения счетчика периодов дескр.
    recv_wrd_cnt : Integer;       //количество принимаемых сырых слов за раз
    proc_wrd_cnt : Integer;       //размер массива обработанных слов
    cur_proc_size, recv_size : LongWord;     //временные переменные для сохранения текущих размеров
    perios_ms : double;  //переменная для сохранения рассчитанного периода
    check_drop : Boolean; //признак, что надо проверить, не превышен ли макс. интервал
    n,m : Word; //текущие значения m и n
    tout: LongWord; //таймаут на прием
  begin
    SetLength(ch_info, phltr51^.LChQnt);
    for ch:=0 to phltr51^.LChQnt-1 do
    begin
      ch_info[ch].fnd_fronts := 0;
      ch_info[ch].cntr := 0;
    end;

    max_cntr :=  Round(IntervalMax*phltr51^.Fs/1000);
    { принимаем всегда слова от всех каналов, при этом по 2 слова на отсчет }
    recv_wrd_cnt := 2 * LTR51_CHANNEL_CNT * phltr51^.TbaseQnt;
    SetLength(rcv_buf, recv_wrd_cnt);
    { после обработки получаем только слова от тех каналов, которые разрешены,
      и по одному слову на отсчет }
    proc_wrd_cnt :=  phltr51^.LChQnt* phltr51^.TbaseQnt;
    SetLength(data, proc_wrd_cnt);

    tout := LTR51_CalcTimeOut(phltr51^, phltr51^.TbaseQnt);


    err:= LTR51_Start(phltr51^);
    if err = LTR_OK then
    begin
      sendLogText('Сбор данных запущен');
      while not stop and (err = LTR_OK) do
      begin
        { Принимаем данные (здесь используется вариант без синхрометок, но есть
          и перегруженная функция с ними) }
        recv_size := LTR51_Recv(phltr51^, rcv_buf, recv_wrd_cnt, tout);
        //Значение меньше нуля соответствуют коду ошибки
        if recv_size < 0 then
          err:=recv_size
        else  if recv_size < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          cur_proc_size := recv_size;
          err:=LTR51_ProcessData(phltr51^, rcv_buf, data, cur_proc_size);
          if err = LTR_OK then
          begin
            cur_proc_size := Trunc(cur_proc_size/phltr51^.LChQnt ) ;
            for i:=0 to cur_proc_size-1 do
            begin
              for ch:=0 to phltr51^.LChQnt-1 do
              begin
                check_drop := false;
                { n содержится в старших 16-битах принятого слова, m - в младших }
                n:= (data[i*phltr51^.LChQnt + ch] shr 16) and $FFFF;
                m:= (data[i*phltr51^.LChQnt + ch]) and $FFFF;
                if n <> 0 then
                begin
                  if n > 1 then
                  begin
                    { если больше одного фронта,
                      то точно определить можем только время последнего.
                      если вели рассчеты, то эту информацию отбрасываем и
                      начинаем рассчет нового периода с последнего фронта }
                    sendChMsg(ch, IntToStr(n) + ' фронтов за один интервал измерения!! Неправильные настройки!');
                    ch_info[ch].fnd_fronts := 1;
                    ch_info[ch].cntr := m;
                  end
                  else
                  begin
                    if ch_info[ch].fnd_fronts = 0 then
                    begin
                      { если найден первый фронт - начинаем считать интервал
                        от его конца }
                      sendChMsg(ch, 'Найден первый фронт');
                      ch_info[ch].fnd_fronts := 1;
                      ch_info[ch].cntr := m;
                    end
                    else if ch_info[ch].fnd_fronts = (ReqFrontCnt-1) then
                    begin
                      { Найден последний фронт. Учитываем время до этого фронта,
                        рассчитываем интервал и начинаем отсчет заново }
                      ch_info[ch].cntr := ch_info[ch].cntr + phltr51^.Base - m;
                      perios_ms := 1000. * ch_info[ch].cntr/phltr51^.Fs;
                      sendChMsg(ch, 'Найден последний фронт. Интервал с первого: ' +
                                    FloatToStrF(perios_ms, ffFixed, 8, 2) + ' мс');

                      {начинаем новый отсчет интервала с последнего фронта }
                      ch_info[ch].cntr := m;
                      ch_info[ch].fnd_fronts := 1;
                    end
                    else
                    begin
                       { для промежуточных фронтов просто прибавляем весь интервал
                         и увеличиваем кол-во найденных фронтов}
                       ch_info[ch].fnd_fronts:=ch_info[ch].fnd_fronts+1;
                       ch_info[ch].cntr:=ch_info[ch].cntr + phltr51^.Base;
                       check_drop := TRUE;
                       sendChMsg(ch, 'Найден промежуточный фронт ' + IntToStr(ch_info[ch].fnd_fronts));
                    end;
                  end;
                end
                else
                begin
                  { n==0 => hltr51.Base отсчетов были без фронта => прибавляем
                    к текущему интервалу }
                  if ch_info[ch].fnd_fronts <> 0 then
                  begin
                      ch_info[ch].cntr := ch_info[ch].cntr + phltr51^.Base;
                      check_drop := TRUE;
                  end;
                end;

                { проверка, что превышен максимальный интервал и нужно сбросить подсчеты }
                if check_drop and (ch_info[ch].cntr > max_cntr) then
                begin
                  sendChMsg(ch, 'Не было последующего фронта за заданный интервал');
                  ch_info[ch].fnd_fronts := 0;
                  ch_info[ch].cntr := 0;
                end;
              end;
            end;
          end;
        end;
      end;

      { По выходу из цикла отсанавливаем сбор данных.
        Чтобы не сбросить код ошибки (если вышли по ошибке)
        результат останова сохраняем в отдельную переменную }
      stoperr := LTR51_Stop(phltr51^);
      if err = LTR_OK then
         err:= stoperr;

      sendLogText('Сбор данных остановлен');   
    end;
  end;
end.
