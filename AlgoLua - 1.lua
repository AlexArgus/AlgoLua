function OnConnected(flag)
    Connected = flag;
end

    local List = {};
	
	function List:Init()
        self.first = 0;
        self.last = -1;
    end;
		
	function List:pushright(value)
        local last = self.last + 1
        self.last = last
        self[last] = value
    end;
	
	function List:popleft()
        local first = self.first
        if first > self.last then error("list is empty") end
        self[first] = nil        -- to allow garbage collection
        self.first = first + 1
    end;
	
	function List:new(o)
      o = o or {};
      setmetatable(o, self);
      self.__index = self;
	  self:Init();
      return o;
    end;
	
	function List:GetEMA2(L)
	    local L_ = L
	    local Last_ = self.last
		local sum = 0
		
	    for i = 1, L_ do 
		    sum = sum + self[Last_ - L_ + i] * i;
	    end;
		  
		sum = 2*sum/(L_*(L_ + 1));
		return sum;
	end;
				
    function GetMiddleSqrtPrice(class,sec)
        local class_ = class;
	    local sec_ = sec;
	    local bid_ = getParamEx(class_, sec_,   'bid').param_value
	    local ask_ = getParamEx(class_, sec_, 'offer').param_value
	    return math.sqrt(bid_*ask_)	    	  
    end;		   	
	
	function MakeRecord(String, file) 
	
	    local String_ = String
	    local class_ = class
		local sec_ = sec

	    local BIDL2PRICE    = getParamEx(class_, sec_,         'bid').param_value;
		local BIDL2QUANTITY = getParamEx(class_, sec_,    'biddepth').param_value;
		local ASKL2PRICE    = getParamEx(class_, sec_,       'offer').param_value;
		local ASKL2QUANTITY = getParamEx(class_, sec_,  'offerdepth').param_value;
		local now_ =	string.gsub(getInfoParam('SERVERTIME'),':','')*1; 
		local position_ = position
		local Balance_  = Balance
		local Flag_ = Flag
	
		message('Haliluya!!! ' .. String_);
	
		file:write(String .. '\t' .. string.format("%.0f", BIDL2PRICE) .. '\t' .. string.format("%.0f", BIDL2QUANTITY) .. '\t' .. 
		            string.format("%.0f", ASKL2PRICE) .. '\t' .. string.format("%.0f", ASKL2QUANTITY) .. '\t' .. 
					string.format("%.0f", position_) .. '\t' .. string.format("%.0f", Balance_ ).. '\t' .. 
					string.format("%.0f", Flag_) .. '\t' .. now_ .. '\n');   
					
		file:flush();
	
		return 
	
	  end;	
	  
-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function     tprint (tbl, indent)
  local Message_ = '';
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) != "table" then
    -- Message_ = Message_ .. formatting .. '\n' .. tprint(v, indent+1)
 -- else
      Message_ = Message_ .. formatting .. v .. '\n'
    end
  end
  message(Message_)
end
	  
	--[[ function table.contains(table, element)
		  -- for _, value in pairs(table) do
			  -- if value == element then
				  -- return true 
			  -- end 
		  -- end
		  -- return false
      -- end ]]-- 		
	
function  GetTradeConditions(N, CT)
	
	    local N_ = N
		local CurrentTime_ = CT
	    local ATR_global_ = ATR_global
		local ATR_Level_  = ATR_Level
		local ATR_Condition_ = (ATR_global_ > ATR_Level_)
		
		--[[
		--local SqrtPrice 
		--local EMA2Fast_last
		--local EMA2Slow_last
		--local EMADiff_last 
		--local Mlast         
		--local MLag
		--local Slast
		--local DiffMS_last   
		--local Blast
		--local BLa]]--
		
		local function GetMSB(N)
	
			local N_ = N
			
			local PriceArray_ = _G[('PriceArray' .. N_)]
			local EMA2Fast_   = _G[('EMA2Fast'   .. N_)]
			local EMA2Slow_   = _G[('EMA2Slow'   .. N_)]
			local EMADiff_    = _G[('EMADiff'    .. N_)]
			local M_          = _G[('M'          .. N_)]
			local S_          = _G[('S'          .. N_)]
			local DiffMS_     = _G[('DiffMS'     .. N_)]
			local B_          = _G[('B'          .. N_)]
		
			local q,p,m,n = _q,_p,_m,_n;
			local class_ = class
			local sec_   = sec
			local SqrtPrice_ = GetMiddleSqrtPrice(class_, sec_);
			
			PriceArray_:pushright(SqrtPrice_);
			-- PriceArray_:popleft();
			
			local EMA2Fast_last_ = PriceArray_:GetEMA2(m)
			EMA2Fast_:pushright( EMA2Fast_last_ );
			-- EMA2Fast_:popleft(); 
			
			local EMA2Slow_last_ = PriceArray_:GetEMA2(n)
			EMA2Slow_:pushright( EMA2Slow_last_ );
			-- EMA2Slow_:popleft(); 
				
			local EMADiff_last_ = EMA2Fast_[ EMA2Fast_.last ] - EMA2Slow_[ EMA2Slow_.last ];
			EMADiff_:pushright( EMADiff_last_ )
			-- EMADiff_:popleft();
					
			local MLag_ = M_[M_.last];
			local Mlast_ = EMADiff_:GetEMA2(q);
			M_:pushright( Mlast_ );
			-- M_:popleft();
			
			local Slast_ = EMADiff_:GetEMA2(p)
			S_:pushright( Slast_ );
			-- S_:popleft();  
					
			local DiffMS_last_ = Mlast_ - Slast_;
			DiffMS_:pushright(DiffMS_last_);
			-- DiffMS_:popleft();
			
			local BLag_ = B_[B_.last];
			local Blast_ = DiffMS_:GetEMA2(q)
			-- B_:pushright( Blast_ );
			-- B_:popleft();
			
			-- return PriceArray, EMA2Fast, EMA2Slow, EMADiff, M, Mlast, MLag, S, DiffMS, B, Blast, BLag;
			return SqrtPrice_, EMA2Fast_last_, EMA2Slow_last_, EMADiff_last_, Mlast_, MLag_, Slast_, DiffMS_last_, Blast_, BLag_
					
        end; -- GetMSB(N)
			
		local SqrtPrice, EMA2Fast_last, EMA2Slow_last, EMADiff_last,
		      Mlast, MLag, Slast, DiffMS_last, Blast, BLag   = 	
		      GetMSB(N_); ------ Минимализм аргументов ------
			   
		-- Локальная функция. Добавляет первый и удаляет последний элементы объектов класса List --------	   
		
		local function pushRightpopLeft(String, element)
             local NN = N_				 
			_G[(String .. NN)]:pushright(element);
		    _G[(String .. NN)]:popleft();
        end	
		
		pushRightpopLeft('PriceArray', SqrtPrice    )
		pushRightpopLeft('EMA2Fast',   EMA2Fast_last)	   
		pushRightpopLeft('EMA2Slow',   EMA2Slow_last)
		pushRightpopLeft('EMADiff',    EMADiff_last )
		pushRightpopLeft('DiffMS',     DiffMS_last  )
		pushRightpopLeft('M',          Mlast        )
		pushRightpopLeft('S',          Slast        )	
		pushRightpopLeft('B',          Blast        )
		
		_G[('M' .. N_ .. 'Lag')] = MLag
		_G[('S' .. N_ .. 'Lag')] = SLag
		_G[('B' .. N_ .. 'Lag')] = BLag	
				
		
		local M60last_, M60Lag_, M20last_, M20Lag_, S60last_, S20last_, B60last_, B20last_, B20Lag_
		
	    if     N_ == 60 then	
		
			M60last_ = Mlast  --
			M60Lag_  = MLag   --
			S60last_ = Slast  --
			B60last_ = Blast  --
			M20last_ = M20[M20.last]
			M20Lag_  = M20Lag
			S20last_ = S20[S20.last]
			B20last_ = B20[B20.last]
			B20Lag_  = B20Lag
				
		elseif N_ == 20 then
		
		    M60last_ = M60[M60.last]  
			M60Lag_  = M60Lag 
			S60last_ = S60[S60.last]
			B60last_ = B60[B60.last]
            M20last_ = Mlast --
			M20Lag_  = MLag  --			 
			S20last_ = Slast -- 
			B20last_ = Blast --
			B20Lag_  = BLag  -- 
			
			
		end 
		
		local OpenLongCondition_ = (M60last_ > 0) and (B60last_ > 0) and (B20last_ > 0) and (B20Lag_ < 0)  and ATR_Condition_;
		local FirstCloseLongCondition_ = (M60last_ > M60Lag_) and (M20last_ < M20Lag_);
		local OpenShortCondition_ = (M60last_ < 0) and (B60last_ < 0) and (B20last_ < 0) and (B20Lag_ > 0) and ATR_Condition_;
		local FirstCloseShortCondition_ = (M60last_ < M60Lag_) and (M20last_ > M20Lag_);
		
		
		message('OpenLongCondition         '             .. tostring(OpenLongCondition_) .. '\n' ..
				'FirstCloseLongCondition   '       .. tostring(FirstCloseLongCondition_) .. '\n' ..
				'OpenShortCondition         '           .. tostring(OpenShortCondition_) .. '\n' ..
				'FirstCloseShortCondition   '     .. tostring(FirstCloseShortCondition_) .. '\n' ..
				'\n' ..
				'ATR_global                      ' .. string.format("%.2f", ATR_global_) .. '\n' ..
				'ATR_Level                       ' .. string.format("%.2f", ATR_Level_ ) .. '\n' ..
				'\n' .. 'N = ' .. N_);
				
		local function round(exact, quantum)
			local coef = 10^quantum
			return math.floor(exact*coef)/coef
		end
				
		M60last_ = round(M60last_, 2) 
	    M60Lag_  = round(M60Lag_,  2) 
	    S60last_ = round(S60last_, 2) 
	    B60last_ = round(B60last_, 2) 
	    M20last_ = round(M20last_, 2) 
        M20Lag_  = round(M20Lag_,  2) 
		S20last_ = round(S20last_, 2) 
		B20last_ = round(B20last_, 2) 
		B20Lag_  = round(B20Lag_,  2)
        ATR_global_ = round(ATR_global_, 2)		
				
		-- message(
		        -- 'M60last_ ' .. M60last_ .. '\n' ..
	            -- 'M60Lag_ '  .. M60Lag_  .. '\n' .. '\n' ..
				-- 'M20last_ ' .. M20last_ .. '\n' ..
				-- 'M20Lag_ '  .. M20Lag_  .. '\n' .. '\n' ..
	            -- 'S60last_ ' .. S60last_ .. '\n' ..
				-- 'S20last_ ' .. S20last_ .. '\n' ..
				-- 'B60last_ ' .. B60last_ .. '\n' .. '\n' ..
				-- 'B20last_ ' .. B20last_ .. '\n' .. 
				-- 'B20Lag_ '  .. B20Lag_  .. '\n' .. '\n' ..
				-- 'N ' .. N_
				-- )	    
				
		file:write(
		       N_       ..                        						'\t'
		    .. M60last_ ..                        						'\t'
	        .. M60Lag_ ..                         						'\t'
			.. M20last_ ..                        						'\t'
			.. M20Lag_ ..                         						'\t'
	        .. S60last_ ..                        						'\t'
			.. S20last_ ..                        						'\t'
	        .. B60last_ ..                        						'\t'
			.. B20last_ ..                        						'\t'
			.. B20Lag_ ..                                               '\t'
			.. ATR_global_ ..											'\t'
	        .. tostring(OpenLongCondition_) ..                          '\t'
			.. tostring(FirstCloseLongCondition_)  ..                   '\t'
	        .. tostring(OpenShortCondition_) ..                         '\t'
			.. tostring(FirstCloseShortCondition_) ..                   '\t'
			.. position ..                                              '\t'
			.. Balance ..											    '\t'
			.. Flag ..						     					    '\t'
			.. CurrentTime_ ..                                          '\t'
			..  '\n')
	
	    file:flush();    	
				
        return 	OpenLongCondition_,  FirstCloseLongCondition_, 
		        OpenShortCondition_, FirstCloseShortCondition_			
				
	end -- GetTradeConditions(N, CT)
		
function  ATR(index)  --------- Calculate Average True Range (ATR) -------------------------
			
			local index_ = index - 1
				
			if (index_ - last_index) > 0 then
				
				local H = data_source:H(index_    );
		        local C = data_source:C(index_ - 1);
		        local L = data_source:L(index_    );
		        local element_ = math.max( math.abs(H - L),
				                           math.abs(H - C),
										   math.abs(C - L))
										   
				if ( element_ > 0.005 * (H + L) ) then -- Не принимаем во внимание "выбросы" больше 1% от медианы цены	
				    last_index = index_ 
					message('Too much element  ' .. element_)
					return 
				end 
				    					   
										   
				local TR_ = TR; 
				TR_:pushright(element_)
				local ATR_ = TR_:GetEMA2(_Period_ATR)   -- На локальном объекте list  функция GetEMA2 должна вычисляться быстрее
				
                local T_ = data_source:T(index_ )
		        local hour_ = T_.hour;
		        local min_  = T_.min;
		
				if (not (hour_ == 10 and min_ < 2) ) then 
		            TR:pushright(element_)
				    TR:popleft();
		        end	
				
				TR:pushright(element_)
				TR:popleft();

                if min_ < 10 then 
				    min_ = tostring(0 .. min_)
				end;				
				
				message(" ATR_global is  " ..  string.format("%.2f", ATR_) .. '\n' ..
						" время последней свечи " .. hour_ .. ":" .. min_ .. '\n')--  .. 
						-- "index  " .. index_);
						
				last_index = index_
				ATR_global = ATR_
				
            end				
			
	end;  -- ATR(index)
		
function  OnInit()
  
    firm_id      = "SPBFUT000000";
	class        = "SPBFUT";
	sec          = "RIU7";
	ACCOUNT      = 'SPBFUT00802';                                          -- Идентификатор счета
	
	SEC_PRICE_STEP = getParamEx(class, sec, "SEC_PRICE_STEP").param_value; -- Минимальный шаг Цены Инструмента
		
	    -- Позиция на начало торгов, передается в глобальную переменную 
	
	if ( getNumberOf('futures_client_holding') ~= 0 )             
	    then position = getItem('futures_client_holding', 0).totalnet;
		else position = 0;
	end;	
	
	message('position ' .. tostring(position) );	
	  
	Balance       = 0;	                     -- Количество неисполненных лотов в активной заявке
	local ttime   = os.time();
	OrderOpenTime = ttime;                   -- Таймер для активной заявки
	PreviousTime  = ttime;                   -- Начальное значение для функции OnParam;
	trans_id      = ttime;                   -- Задает начальный номер (ID) Лимитной заявки
	stop_orders_trans_id = 2*trans_id;       -- Задает начальный номер (ID) Стоп-заявки
	Flag          = 0;                       -- Флаг разрешения операций;
    -- CloseFlag     = nil;                  -- Флаг разрешения для Стоп-Ордеров
	Code = nil; 							 -- Флаг открытия или закрытия сделки
    StopOrderFlag = false;	                 -- Флаг разрешения для Стоп-Ордеров
	 -- SessionStatus = 10;                  -- Торговля производится только при SessionStatus == 0  – основная / вечерняя сессия; 
	Bit0 = nil;                              -- Флаг Активности Стоп-заявки
	Bit5 = nil;                              -- Флаг ожидания активации Стоп-заявкой
	CBF2 = nil;                              -- Флаг направления сделки в Лимитной заявке
	  
	_q,_p,_m,_n = 3, 9, 13, 26;
	
	_Period_ATR = 2*60;                       -- ATR за 2 последних часа --
		   
	
	_ShortTimeInterval, _LongTimeInterval = 37, 113;  -- периоды EMA в секундах
	 	
	P = GetMiddleSqrtPrice(class,sec)                -- вычисляет среднюю геометрическую bid/ask
	
	ATR_Level = 0.0007 * P -- 70/100'000             -- вычисляет уровень ATR выше которого можно открываться.
	                                                 -- При цене 80000, уровень будет 56.
	
	-- Create Initial Values --
	
	PriceArray60     = List:new(); --PriceArray60:Init();
	PriceArray20     = List:new(); --PriceArray20:Init();
	EMA2Slow60       = List:new(); --EMA2Slow60:Init();
	EMA2Fast60       = List:new(); --EMA2Fast60:Init();
	EMADiff60        = List:new(); --EMA2Diff60:Init();
	M60              = List:new(); --M60:Init();
	S60              = List:new(); --S60:Init();
	B60              = List:new(); --B60:Init();
	DiffMS60         = List:new(); --DiffMS60:Init();
	EMA2Slow20       = List:new(); --EMA2Slow20:Init();
	EMA2Fast20       = List:new(); --EMA2Fast20:Init();
	EMADiff20        = List:new(); --EMA2Diff20:Init();
	M20              = List:new(); --M20:Init();
	S20              = List:new(); --S20:Init();
	B20              = List:new(); --B20:Init();
	DiffMS20         = List:new(); --DiffMS20:Init();
	
	TR               = List:new(); --Для вычислени ATR
	
	M60Lag           = 0;
	M20Lag           = 0;
	B60Lag           = 0;
	B20Lag           = 0;
	
	
	
	for i = 0, _n - 1 do
	  PriceArray60:pushright(P)
	  PriceArray20:pushright(P)
	  EMA2Slow60:pushright(P)
	  EMA2Slow20:pushright(P)
    end;
	
	for i = 0, _m - 1 do
	  EMA2Fast60:pushright(P)
	  EMA2Fast20:pushright(P)
	end;
	
	for i = 0, _p - 1 do
      S60:pushright(0)
	  S20:pushright(0)
	  EMADiff60:pushright(0)
	  EMADiff20:pushright(0)
	end;
	
	for i = 0, _q - 1 do
	    M60:pushright(0) 
		B60:pushright(0) 
		M20:pushright(0) 
		B20:pushright(0)
		DiffMS60:pushright(0)
		DiffMS20:pushright(0)
	end;
	
	M60last = M60[M60.last];
	B60last = B60[B60.last];
	M20last = M20[M20.last];
	B20last = B20[B20.last];
	
	----- Получем данные для вычисления ATR ------------------------
	
	local Error = '';
	
	data_source, Error = CreateDataSource(class, sec, INTERVAL_M1); -- Создание источника данных по инструменту 'sec'	
	
    local last_index;
	
	if ( data_source ~= nil ) then -- Подключение источника данных		
		    last_index = data_source:Size() - 1;
			message("Источник данных по инструменту " .. sec ..
         			" успешно подключен \n\n" ..
                    "Количество свечей " .. tostring(last_index + 1) );
            IsRun = true;					
	else 
		    message("Что-то пошло не так ... " .. Error .. "\n");
			IsRun = false;
			return;
	end;
	
	sleep(3000) -- Время необходимое для получение данных по инструменту
	
	--------- Стартовые данные для True Range -----------------------
	
	for index_ = (last_index - _Period_ATR), last_index do
	
	    local H = data_source:H(index_);
		local C = data_source:C(index_ - 1);
		local L = data_source:L(index_   );
		
		local element = math.max( math.abs(H - L), math.abs(H - C), math.abs(C - L) );
		
		local T_    = data_source:T(index_ )
		local hour_ = T_.hour;
		local min_  = T_.min;
		
		-- TR:pushright(element)
		
		if (not (hour_ == 10 and min_ < 2) ) then 
		    TR:pushright(element)
		else 
		    TR:pushright(TR[TR.last])
		    message('Pass candle \n')	
		end
		
	end;
	
	ATR_global = TR:GetEMA2(_Period_ATR);
	
	message("ATR_global is  " ..  string.format("%.2f", ATR_global) .. '\n')
    
    local fileOpentype = 'w+'	
	
	filePath = 'C:\\Users\\Alexandr\\Desktop\\Trading\\Lua\\'
	file = io.open(filePath .. 'MSBLog2.txt', fileOpentype);
	file:write('N' .. '\t' ..
	           'M60' .. '\t' .. 'M60Lag1' .. '\t'  .. 'M20' .. '\t' .. 'M20Lag1' .. '\t' ..
			   'S60' .. '\t' .. 'S20' .. '\t' .. 
			   'B60' .. '\t' ..  'B20' .. '\t' .. 'B20Lag1' .. '\t' .. 
			   'ATR' .. '\t' ..
	           'OLong' .. '\t' .. 'CLong' .. '\t' .. 'OShort' .. '\t' .. 'CShort' .. '\t' .. 
			   'Pos' .. '\t' .. 'Bal' .. '\t' .. 'Flag' .. '\t' .. 'Time' .. '\n');
	file:flush();
	
	Deals = io.open(filePath .. 'Deals2.txt', fileOpentype);
	Deals:write('Type' .. '\t' .. 'Bid' .. '\t' .. 'BidSize' .. '\t' ..
	            'Ask' .. '\t' .. 'AskSize' .. '\t' .. 'Position' .. '\t' ..
				'Time' .. '\n');
	Deals:flush();
	
	Timing = io.open(filePath .. 'Timing.txt', fileOpentype);
	Timing:write('hour' .. '\t' .. 'min' .. '\t' .. 'sec' .. '\t' .. 'ms' .. '\t' .. 
				 'OOTime ' .. '\t\t' .. 'Pos' .. '\t' .. 'Bal' .. '\t' .. 'Quant' .. '\t' .. 
				 'Flag' .. '\t' .. 'CBF0' .. '\t' .. 'CBF1' .. '\t' .. 'CBF2' .. '\t' .. 'CBF3' .. '\t' ..
				 'NumberOforder' .. '\n' );
	Timing:flush();
	
	Futures = io.open(filePath .. 'Futures.txt', fileOpentype);
	Futures:write('position' .. '\t' .. 'OB' .. '\t' .. 'OS' .. '\t' .. 'time' .. '\t' .. 'SessionStatus' .. '\t' .. 'F' .. '\n') 
	Futures:flush();
	
end; -- OnInit
 
function  main() 


    --[[
    local count = 0
    
    while (not Connected) do
        sleep(15000);
		count = count + 1
		message('count  ' .. tostring(count));
    end
     --]]--
	
	--[[
	-- OpenShortCondition = true; --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Не забыть убрать!!!
	
	Operation, Price, trans_id = Trade( 'B', _MaxQuantityOfPositions - position, 'OPEN' );
	
	sleep(5000);
	
	-- message('_MaxQuantityOfPositions - position_ = ' .. _MaxQuantityOfPositions - position_)
	-- Operation, Price, trans_id = FastTrade( 'S', _MaxQuantityOfPositions - position, 'CLOSE' );
	--]]--

    ---------- Calculate ATR on Callback() -------------------------------
	
	data_source:SetUpdateCallback(ATR);
	
    ----------------------------------------------------------------------
	
    local   work_time = {100100, 135900, 140400, 154430, 160005, 184455, 190030, 234430} -- интервалы времени, когда можно торговать;
	
	local   STARTTIME    = getParamEx(class, sec, 'STARTTIME'   ).param_value*1  -- STRING Начало основной сессии 
	local	ENDTIME      = getParamEx(class, sec, 'ENDTIME'     ).param_value*1  -- STRING Окончание основной сессии 
	local	EVNSTARTTIME = getParamEx(class, sec, 'EVNSTARTTIME').param_value*1  -- STRING Начало вечерней сессии 
	local	EVNENDTIME   = getParamEx(class, sec, 'EVNENDTIME'  ).param_value*1  -- STRING Окончание вечерней сессии 
	local	MONSTARTTIME = getParamEx(class, sec, 'MONSTARTTIME').param_value*1  -- STRING Начало утренней сессии 
	local	MONENDTIME   = getParamEx(class, sec, 'MONENDTIME'  ).param_value*1  -- STRING Окончание утренней сессии
	
	message('STARTTIME     ' .. STARTTIME    .. '\n' ..
	        'ENDTIME       ' .. ENDTIME      .. '\n' ..
			'EVNSTARTTIME  ' .. EVNSTARTTIME .. '\n' ..
			'EVNENDTIME    ' .. EVNENDTIME   .. '\n' ..
			'MONSTARTTIME  ' .. MONSTARTTIME .. '\n' ..
			'MONENDTIME    ' .. MONENDTIME   .. '\n' );
			 --]]--
	
        local  WarmUpTime = os.time() + 5*60;    -- Разогрев системы 5 минут
		local CountWarmUpTime = 0;
		
		while (os.time() <  WarmUpTime) do
            sleep(15000);
		    CountWarmUpTime = CountWarmUpTime + 1
		    message('CountWarmUpTime = ' .. tostring(CountWarmUpTime));
      end
	

    while (IsRun) do -- SessionStatus == 0  основная / вечерняя сессия;
	    
		local _MaxQuantityOfPositions = 2;       -- максимальное количество позиций с которым можно открываться	
	    local _WaitingTime            = 60;	     -- время активности заявок в секундах
		
    --[[
      local countWhile = 0
    
      while (not Connected) do
        sleep(15000);
		countWhile = countWhile + 1
		message('countWhile  ' .. tostring(countWhile));
      end
    --]]-- 	
	
	  local nowtime         = string.gsub(getInfoParam('SERVERTIME'),':','')*1;            -- текущее время
	  local SessionStatus_2 = tonumber(getParamEx(class, sec, "status").param_value)	
	  
	  --[[
	  if ( math.fmod(os.time() + 5, _LongTimeInterval) == 0 ) then
	      if     SessionStatus ==  0 then message('основная / вечерняя сессия')  
		  elseif SessionStatus ==  1 then message('начался промклиринг')
		  elseif SessionStatus ==  2 then message('завершился промклиринг')
		  elseif SessionStatus ==  3 then message('начался основной клиринг')
		  elseif SessionStatus ==  4 then message('основной клиринг,' .. '\n новая сессия назначена')
		  elseif SessionStatus ==  5 then message('завершился основной клиринг ')
		  elseif SessionStatus == 10 then message('Торги еще не открыты')
	      end
		  message('\n' .. 'SessionStatus_2 =  ' .. SessionStatus_2);
      end
      --]]--	  
	
	  sleep(990)	
	
	--------------------- Открытие и закрытие позиций на основании сигналов -------------
	
      local timecond = 	( (nowtime > work_time[3]) and  (nowtime < EVNENDTIME) ) or position ~= 0;   
	  
	  if timecond then
	  
	   if ( SessionStatus_2 == 1  ) then  -- Разогрев Системы 5 минут // Нужно переделать и убрать разогрев!!!
	    
		local position_ = position
	    local BalanceFlag_ = (Balance == 0 and Flag == 0)
		local CloseEvnSessionCond = (nowtime < EVNENDTIME - 60*10) -- Открываем позиции не позже 10 минут до закрытия вечерней Сессии
		
		if     ( OpenLongCondition  and (not FirstCloseLongCondition) and CloseEvnSessionCond and
		         BalanceFlag_  and (_MaxQuantityOfPositions - position_) ~= 0 )  then
				 
		         MakeRecord('OpenLong', Deals);
		         Operation, Price, trans_id = Trade('B', _MaxQuantityOfPositions - position_, 'OPEN');
			
		elseif ( FirstCloseLongCondition and position_ > 0 and BalanceFlag_ )  then
		
		         MakeRecord('CloseLong', Deals);
		         Operation, Price, trans_id = Trade('S', position_, 'CLOSE');
	--[[--		
        elseif ( OpenShortCondition and position_ > 0 and BalanceFlag_ )  then
		
		         MakeRecord('CloseLongByShort', Deals);
		         Operation, Price, trans_id = Trade('S', _MaxQuantityOfPositions + position_, 'OPEN');
	 --]]--			 
			
		elseif ( OpenShortCondition and (not FirstCloseShortCondition) and CloseEvnSessionCond and
          		 BalanceFlag_  and (_MaxQuantityOfPositions + position_) ~= 0) then
				 
		         MakeRecord('OpenShort', Deals);
		         Operation, Price, trans_id = Trade('S', _MaxQuantityOfPositions + position_, 'OPEN' );
				 
		elseif ( FirstCloseShortCondition and position_ < 0 and BalanceFlag_ )  then
		
		         MakeRecord('CloseShort', Deals);
		         Operation, Price, trans_id = Trade('B', - position_, 'CLOSE');
	--[[--			 
		elseif ( OpenLongCondition and position_ < 0 and BalanceFlag_ )  then
		
		         MakeRecord('CloseShortByLong', Deals);
		         Operation, Price, trans_id = Trade('B', _MaxQuantityOfPositions - position_, 'OPEN');
	--]]--			 
		end;
		
		sleep(10)
		
		-------------------------------------------------
		-- Флаг для избежания удваивания позиций. Подумать о контроле через колбеки!
	    if (Flag ~= 0) then Flag = Flag - 1 end;
		-------------------------------------------------
		
		--- Перебирает ТАБЛИЦУ ЗАЯВОК и отправляет TakeProfitOrder -- 
		--[[
		if CloseFlag == 'OPEN' then
		
			for i = getNumberOf('orders') - 1, 0 do
			
				local order = getItem('orders', i);
				 
				if order.trans_id == trans_id then    -- Если заявка по отправленной транзакции ИСПОЛНЕНА (возмжно частично)
				
				   local Operation_
				   local Direction_ = CheckBit(order.flags, 2)
				   local TakeProfitOrderPrice_ = order.price
				   
				   message('CheckBit  '    .. Direction_            .. '\n' ..
				           'order.price  ' .. TakeProfitOrderPrice_ .. '\n'  )
                            						   
				   if Direction_ == 1 then Operation_ = 'B' else Operation_ = 'S' end;
				   trans_id = TakeProfitOrder(Operation_, TakeProfitOrderPrice_); -- Отправляет TakeProfitOrder
				   message('i = ' .. i);
                   -- CloseFlag = nil;				   
				   break; --Прерывает цикл FOR
				end;
				
			 end;
			 
			 -- message('Один')
			 
		elseif CloseFlag == 'CLOSE' then 		    
 
			 for i = getNumberOf('stop_orders') - 1, 0 do
			 
				local order = getItem('stop_orders', i);
				message('order_num      ' .. order.order_num .. '\n' ..
						'stopOrder_num  ' .. tostring(stopOrder_num)  )
				 
				if order.order_num == stopOrder_num then --Если заявка по отправленной транзакции ИСПОЛНЕНА				   
				   trans_id = KillAllStopOrders();       -- закрываем все стоп-заявки
                   -- CloseFlag = nil;				   
				   break; --Прерывает цикл FOR
				end;
		    end;
			
			 --message('Два')
		
		end;
		--]]--
		 
		 -------------------------------------------------
	
	-- После выставления ордера ждем WaitingTime = 1 мин, затем снимаем ордер.
	-- В случае закрывающего ордера, после истечения времени выставляем Market order (KillPosition)
	
		local OrderOpenTime_ = OrderOpenTime;
		local DiffTime = os.difftime( os.time(), OrderOpenTime_ ); 	
	
		if Balance ~= 0 then 
		
			Flag = 2;
			
			if (DiffTime >= _WaitingTime) then
		     -- local totalnet = math.abs(position);
				trans_id = RemoveTransaction(Operation, Code);
				message('Code =  ' .. tostring(Code) );
			end;	
						
		end;
	
	----------- Закрываем все открытые позиции перед концом сессий ----------------------
	
        -- local nowtime =	string.gsub(getInfoParam('SERVERTIME'),':','')*1;
		-- local cond1 = (nowtime > 184000) and (nowtime < 184450);
		local EndSession =  nowtime > EVNENDTIME - 60*2; -- Закрываем позиции за 2 минуты до конца сессии	
		
		if (  EndSession ) and position ~= 0 then
		
			if position > 0 then
			    trans_id = KillPosition('S');	
			elseif 	position < 0 then
			    trans_id = KillPosition('B');
			end;
			
			Flag = 2; 
			
		end; -- if (  EndSession ) and position ~= 0 then

       end;  -- 'SessionStatus_2 == 1'		
	
	  end;   -- timecond
	
     end;    -- while (IsRun) do
   
   end;      -- main

function  OnStop()   
   file       :close();
   Deals      :close();
   Timing     :close();
   Futures    :close();
   data_source:Close();
   IsRun  =  false;   
end;   --OnStop

function  OnOrder(order)
	   
	  numberOforder = order.order_num;
	  message('numberOforder  ' .. numberOforder);
	  
	  local flag = order.flags
	  local CBF0 = CheckBit(flag, 0) -- Активна/НЕ Активна
	  local CBF1 = CheckBit(flag, 1) -- Снята/НЕ Снята
	        CBF2 = CheckBit(flag, 2) -- Покупка/Продажа -- Глобальная переменная
	  local CBF3 = CheckBit(flag, 3) -- Limit/Market
	  local Balance_
	  
	  if CBF1 == 0 then
	      Balance_ = order.balance; 
	  else
       	  Balance_ = 0;
	  end;

      Balance = Balance_
      OrderOpenTime = os.time();
	  
	  message('numberOforder       = ' .. numberOforder .. '\n' ..
			  'OrderOpenTime       = ' .. OrderOpenTime) 
	  
	  local TradeTime = order.datetime;
	  local Quantity_ =  order.qty;
	
	  Timing:write(TradeTime.hour .. '\t' ..
	               TradeTime.min  .. '\t' ..
			       TradeTime.sec  .. '\t' ..
				   TradeTime.ms   .. '\t' ..  
				   OrderOpenTime  .. '\t' ..				   
				   position       .. '\t' ..
				   Balance        .. '\t' ..
				   Quantity_      .. '\t' ..
				   Flag           .. '\t' .. 
				   CBF0           .. '\t' ..
				   CBF1           .. '\t'..
			       CBF2           .. '\t' ..
			       CBF3           .. '\t' ..
				   numberOforder  .. '\t' ..
				   'Order'        .. '\n' 
				   )
       Flag = 2;				   
				   				    			  	  
end;

function  OnStopOrder(stop_order)

    stopOrder_num = stop_order.order_num
	
	local StopOrderFlags = stop_order.flags
	      Bit0 =  CheckBit(StopOrderFlags, 0 ) -- Активна/НЕ Активна
	local Bit1 =  CheckBit(StopOrderFlags, 1 ) 
	local Bit2 =  CheckBit(StopOrderFlags, 2 )
	local Bit3 =  CheckBit(StopOrderFlags, 3 )
	      Bit5 =  CheckBit(StopOrderFlags, 5 ) -- Ожидает Активации/Активирована 
	local Bit6 =  CheckBit(StopOrderFlags, 6 )
	local Bit8 =  CheckBit(StopOrderFlags, 8 )
	local Bit9 =  CheckBit(StopOrderFlags, 9 )
	local Bit10 = CheckBit(StopOrderFlags, 10)
	local Bit11 = CheckBit(StopOrderFlags, 11)
	local Bit12 = CheckBit(StopOrderFlags, 12)
	local Bit13 = CheckBit(StopOrderFlags, 13)
	local Bit15 = CheckBit(StopOrderFlags, 15)
	message('stopOrder_num  = ' .. stopOrder_num .. '\n' ..
			'Bit0 = '  .. tostring(Bit0)  .. '\n' .. 
	        'Bit1 = '  .. tostring(Bit1)  .. '\n' ..
			'Bit2 = '  .. tostring(Bit2)  .. '\n' ..
			'Bit3 = '  .. tostring(Bit3) .. '\n' ..
			'Bit5 = '  .. tostring(Bit5) .. '\n' ..
			'Bit6 = '  .. tostring(Bit6)  .. '\n' ..
			'Bit8 = '  .. tostring(Bit8)  .. '\n' ..
			'Bit9 = '  .. tostring(Bit9)  .. '\n' ..
			'Bit10 = ' .. tostring(Bit10) .. '\n' ..
			'Bit11 = ' .. tostring(Bit11) .. '\n' ..
			'Bit12 = ' .. tostring(Bit12) .. '\n' ..
			'Bit13 = ' .. tostring(Bit13) .. '\n' ..
			'Bit15 = ' .. tostring(Bit15) .. '\n' ..
			'LinkedOrder = ' .. tostring(stop_order.linkedorder));
			
	tprint(stop_order, 0) -- Выводит сообщение о содержимом таблицы stop_order
			
     if     (Bit0 == 0 or Bit5 == 0) then 
	    StopOrderFlag = false
		message('Bit0 = ' ..Bit0 .. ', Stop Order is not Active' .. '\n' ..
                'Bit5 = ' ..Bit5 .. ', Stop Order is not waiting Activation''\n' ..
                'StopOrderFlag = ' .. tostring(StopOrderFlag) .. '\n' ..
				'OnStopOrder');
     elseif (Bit0 == 1 and Bit5 ==1) then
        StopOrderFlag = true
		message('Bit0 = ' ..Bit0 .. ', Stop Order is Active' .. '\n' ..
                'Bit5 = ' ..Bit5 .. ', Stop Order is waiting Activation''\n' ..
                'StopOrderFlag = ' .. tostring(StopOrderFlag) .. '\n' ..
				'OnStopOrder');	 
	 end;
	 
end;

function  OnTrade(trade)

    Flag = 2;
	
    local TradeTime = trade.datetime;			 
	local flag = trade.flags;
	local Quantity_ = trade.qty;
    local TradeNumberOforder_ = trade.order_num;	
	 
	local CBF0 = CheckBit(flag, 0) -- Активна/НЕ Активна
	local CBF1 = CheckBit(flag, 1) -- Снята/НЕ Снята
	local CBF2 = CheckBit(flag, 2) -- Покупка/Продажа
	local CBF3 = CheckBit(flag, 3) -- Limit/Market
	
	Timing:write(TradeTime.hour            .. '\t' ..
	             TradeTime.min             .. '\t' ..
			     TradeTime.sec             .. '\t' ..
				 TradeTime.ms              .. '\t' ..				 
				 position                  .. '\t' ..
				 Balance                   .. '\t' ..
				 Quantity_                  .. '\t' ..
				 Flag                      .. '\t' ..
				 os.time()                 .. '\t' ..
				 tostring(CBF0)            .. '\t' ..
				 tostring(CBF1)            .. '\t' ..
			     tostring(CBF2)            .. '\t' ..
			     tostring(CBF3)            .. '\t' .. '\t' .. '\t' .. 'T' ..
				 tostring(TradeNumberOforder_) .. '\n'
				 )		
end;

function  OnTransReply(trans_reply)

        local trans = trans_reply;
		local Code_ = trans_reply.brokerref;
              Code = Code_;           -- Обновляем Глобальную переменную 
		local Status_ = trans.status;
		
		if Status_ == 3 then 
		
		   if Code_ == 'OPEN' and StopOrderFlag == false then
		   
		      local Operation_ = Operation;           -- Направление заявки 'BUY' или 'SELL'
		      local Price_ = trans.price;             -- Цена  последнего лимитного ордера
			  local numberOforder_ = trans.order_num; -- Номер последнего лимитного ордера
			  message('OnTransReply' .. '\n' ..
			          'Operation_     = ' .. Operation_ .. '\n' ..
					  'takeProfitOrderPrice_ = ' .. tostring(Price_) .. '\n' .. 
				      'numberOforder  = ' .. numberOforder_ .. '\n'          );	
					  
			  stop_orders_trans_id = TakeProfitOrder(Operation_, Price_, numberOforder_) 
			  
		   elseif Code_ == 'CLOSE' and StopOrderFlag == true then 
		   
              trans_id             = KillStopOrder();
			  
           end	
		   
		end;	
        message('Trans_Status  = ' ..  Status_ .. '\n\n' .. 
		        trans.result_msg .. '\n\n' ..
				'Code =          ' .. Code_ .. '\n' ..
				'StopOrderFlag = ' .. tostring(StopOrderFlag));
				

end;

function  OnFuturesClientHolding(fut_pos) 

   position = fut_pos.totalnet; -- Передает значение в глобальную переменную
   
   local OB = fut_pos.openbuys;
   local OS = fut_pos.opensells;
-- local StartPositions = fut_pos.startnet;
-- SessionStatus = fut_pos.session_status; 
   
   if (OB ~= 0) or (OS ~= 0) then Flag = 2 end;	 

   local nowtime_ =	string.gsub(getInfoParam('SERVERTIME'),':','')*1;   
   
   Futures:write(position .. '\t' .. OB .. '\t' .. OS .. '\t' .. nowtime_ .. '\t' .. SessionStatus .. 'F' .. '\n')

 end;
 
function  OnParam(class,sec)
 
     local CurrentTime_ = os.time()
	 
	 local PreviousTime_      = PreviousTime
	 --[[local sec_ = sec
	 local ACCOUNT_ = ACCOUNT
	 local firmid_  = firm_id]]--
	 
	 -- Получение Главных Индикаторов  и Торговых сигналов --
	 	 
	 if (CurrentTime_ - PreviousTime_) >= 1 then
	 
	      if math.fmod(CurrentTime_, _LongTimeInterval) == 0 then
		     local x = os.clock();
			 OpenLongCondition, FirstCloseLongCondition, 
			 OpenShortCondition, FirstCloseShortCondition =   
			 GetTradeConditions(60, CurrentTime_)
			 local y = os.clock() - x;
			 message('Функция GetTradeConditions \nзаняла ' .. y .. ' секунд')			 
			 ------------------------------------
			 PreviousTime = CurrentTime_
		 end;
		 
		  if math.fmod(CurrentTime_, _ShortTimeInterval) == 0 then
		     local x = os.clock();
			 OpenLongCondition, FirstCloseLongCondition, 
			 OpenShortCondition, FirstCloseShortCondition =
			 GetTradeConditions(20, CurrentTime_)
			 local y = os.clock() - x;
			 message('Функция GetTradeConditions \nзаняла ' .. y .. ' секунд')
			 ------------------------------------
			 PreviousTime = CurrentTime_
		 end
		 
		 ------------------------------------		 
	 
	 end;
	  
 end;

function  CheckBit(flags, bit)
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= 'number' then error("Предупреждение!!! Checkbit: 1-й аргумент не число!"); end;
   if type(bit) ~= 'number' then error("Предупреждение!!! Checkbit: 2-й аргумент не число!"); end;
   local RevBitsStr  = ""; -- Перевернутое (задом наперед) строковое представление двоичного представления переданного десятичного числа (flags)
   local Fmod = 0; -- Остаток от деления
   local Go = true; -- Флаг работы цикла
   while Go do
      Fmod = math.fmod(flags, 2); -- Остаток от деления
      flags = math.floor(flags/2); -- Оставляет для следующей итерации цикла только целую часть от деления
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- Добавляет справа остаток от деления
      if flags == 0 then Go = false; end; -- Если был последний бит, завершает цикл
   end;
   -- Возвращает значение бита
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;

function  Trade(Operation, quantity, Code)

        local quantity_ = quantity
		local trans_id = trans_id + 1;
		local Price;
		local Operation = Operation;
		local ClientCode_ = Code;
		local class = class;
	    local sec = sec;
	    local ACCOUNT = ACCOUNT;	    
	
       if     Operation == 'B' then		
		    Price = getParamEx(class, sec,   'bid').param_value*1  	
	   elseif Operation == 'S' then
		    Price = getParamEx(class, sec, 'offer').param_value*1 	
	   end; 	   

    message(Operation .. '\n' .. 
	        Price .. '\n' .. 
			trans_id .. '\n' .. 
			' Quantity  ' .. quantity_)	   
  
   
   local Transaction={ 
   
	 ['TRANS_ID']    = tostring(trans_id),
	 ['ACTION']      = 'NEW_ORDER',
	 ['CLASSCODE']   = class,
	 ['SECCODE']     = sec,
	 ['OPERATION']   = Operation, 
	 ['TYPE']        = 'L',       
	 ['QUANTITY']    = tostring(quantity_),      
	 ['ACCOUNT']     = ACCOUNT,
	 ['PRICE']       = tostring(Price),
     ['CLIENT_CODE'] = ClientCode_	 
   }
   
   res = sendTransaction(Transaction) 
      
      if string.len(res) ~= 0 then
         message("Trade send message = " .. tostring(res), 1)
      end	  
	
	return Operation, Price, trans_id
     
 end;
 
 function TakeProfitOrder(Operation, Price, numberOforder)

		local stop_orders_trans_id_ = stop_orders_trans_id + 1;
		local order_key = numberOforder;
		local Operation_ = Operation;
		local class = class;
	    local sec = sec;
	    local ACCOUNT = ACCOUNT;
        local SEC_PRICE_STEP_ = SEC_PRICE_STEP;
        local PriceTakeProfit_;		
        local ReverseOperation_;
		local Price_ = Price
		local Delta_ = math.floor(2 * ATR_global/SEC_PRICE_STEP_)*SEC_PRICE_STEP_;
		

        if     (Operation_ == 'B') then
		    ReverseOperation_ = 'S';
			PriceTakeProfit_ = Price_ + Delta_;
		elseif (Operation_ == 'S') then
    		ReverseOperation_ = 'B';
			PriceTakeProfit_ = Price_ - Delta_;
		end;

    message('Operation ' ..  Operation   .. '\n' ..
	        'Price ' .. PriceTakeProfit_ .. '\n' ..
			'Transaction  ' .. stop_orders_trans_id_)   
  
   
   local Transaction={ 
     ['ACTION']                               = 'NEW_STOP_ORDER',
	 ['TRANS_ID']                             = tostring(stop_orders_trans_id_),
	 ['STOP_ORDER_KIND']                      = 'ACTIVATED_BY_ORDER_TAKE_PROFIT_STOP_ORDER',
	 ['BASE_ORDER_KEY']                       = tostring(order_key),
	 ['USE_BASE_ORDER_BALANCE']               = 'YES',
	 ['ACTIVATE_IF_BASE_ORDER_PARTLY_FILLED'] = 'YES',
	 ['SPREAD']                               = tostring(50),
	 ['OFFSET']                               = tostring(30),
	 ['OFFSET_UNITS']                         = 'PRICE_UNITS',
	 ['SPREAD_UNITS']                         = 'PRICE_UNITS',
	 ['STOPPRICE']                            = tostring(PriceTakeProfit_),
	 ["CLIENT_CODE"]                          = "TakeProfitOrder",
	 ['OPERATION']                            = ReverseOperation_,
	 ['SECCODE']                              = sec,
	 ['CLASSCODE']                            = class,     
	 ['ACCOUNT']                              = ACCOUNT 	  
   }			  			  
			     
   res = sendTransaction(Transaction) 
      
      if string.len(res) ~= 0 then
         message("TakeProfitOrder send message = " .. tostring(res), 1)
      end
	
	return stop_orders_trans_id_
     
 end;
 
 function KillStopOrder()
     
	 local trans_id = trans_id + 1;
	 
     local Transaction={ 
     ['ACTION']                               = 'KILL_STOP_ORDER',
	 ['TRANS_ID']                             = tostring(trans_id),
	 ['STOP_ORDER_KEY']                       = tostring(stopOrder_num),
	 ['SECCODE']                              = sec,
	 ['CLASSCODE']                            = class,     
	 ['ACCOUNT']                              = ACCOUNT,
     ["CLIENT_CODE"]                          = "OPEN"	 
   }			  			  
			     
   local res = sendTransaction(Transaction) 
      
      if     string.len(res) ~= 0 then
	  
         message("KillAllStopOrders send message = " .. tostring(res), 1) -- Ошибка отправки 
	  
      end;  
	
   return trans_id
 
 end;

function  RemoveTransaction(Operation, Code)
       
	   local trans_id  = trans_id + 1;
   
	   local Transaction={	   
        ['TRANS_ID']   = tostring(trans_id),
        ['ORDER_KEY']  = tostring(numberOforder),
	    ['ACTION']     = 'KILL_ORDER',
        ['CLASSCODE']  = class,
	    ['SECCODE']    = sec,
	 -- ['OPERATION']  = Operation, 
	 -- ['TYPE']       = 'L', 
	 -- ['QUANTITY']   = tostring(quantity_),
	 -- ['ACCOUNT']    = ACCOUNT,
	 -- ['PRICE']      = tostring(Price) 
		}	
	
	  res = sendTransaction(Transaction) 
      
      if string.len(res) ~= 0 then
         message("RemoveTransaction send message = " .. tostring(res), 1)
      end
	   
	   if position_ ~= 0 and (Code == 'CLOSE') then
      	   trans_id = KillPosition(Operation)
	   end
	   
	   return trans_id

 end; 
 
function  KillPosition(Operation)

    local quantity_ = math.abs(position);
	local trans_id  = trans_id + 1-- local Operation_ = Operation;
  --local class = class
  --local sec = sec;
  --local Price = GetMiddleSqrtPrice(class,sec);
	local Price;
  --local ACCOUNT = ACCOUNT;
  --local SEC_PRICE_STEP_ = SEC_PRICE_STEP;
    local Delta = 15 * SEC_PRICE_STEP;
			
	if Operation == 'B' then			
	    Price = getParamEx(class, sec, 'offer').param_value + Delta;					
    elseif Operation == 'S' then	
		Price = getParamEx(class, sec,   'bid').param_value - Delta;						
	end;    

     local Transaction = 
	 { 
		 ['TRANS_ID']   = tostring(trans_id),
		 ['ACTION']     = 'NEW_ORDER',
		 ['CLASSCODE']  = class,
		 ['SECCODE']    = sec,
		 ['OPERATION']  = Operation, 
		 ['TYPE']       = 'M',       
		 ['QUANTITY']   = tostring(quantity_),       
		 ['ACCOUNT']    = ACCOUNT,
		 ['PRICE']      = tostring(Price)
     }			  			  
			     
   res = sendTransaction(Transaction) 
      
      if string.len(res) ~= 0 then
         message("KillPosition send message = " .. tostring(res), 1)
      end 
   
   return trans_id
     
 end;
 
 ---[[
function  FastTrade(Operation, quantity, Code)

    local quantity = quantity
	local trans_id  = trans_id + 1;
	local Operation = Operation;
	local class = class;
	local sec = sec;
	--local Price = GetMiddleSqrtPrice(class,sec);
	local Price;
	local CODE_ = Code;
	local ACCOUNT = ACCOUNT;
	local SEC_PRICE_STEP = SEC_PRICE_STEP;
    local Delta = 20 * SEC_PRICE_STEP;
			
	if Operation == 'B' then			
	    Price = getParamEx(class, sec, 'offer').param_value - Delta;					
    elseif Operation == 'S' then	
		Price = getParamEx(class, sec,   'bid').param_value + Delta;						
	end;    

     local Transaction = 
	 { 
		 ['TRANS_ID']   = tostring(trans_id),
		 ['ACTION']     = 'NEW_ORDER',
		 ['CLASSCODE']  = class,
		 ['SECCODE']    = sec,
		 ['OPERATION']  = Operation,
         ['CLIENT_CODE']= CODE_,		 
		 ['TYPE']       = 'L',       
		 ['QUANTITY']   = tostring(quantity),       
		 ['ACCOUNT']    = ACCOUNT,
		 ['PRICE']      = tostring(Price)
     }			  			  
			     
   res = sendTransaction(Transaction) 
      
      if string.len(res) ~= 0 then
         message("FastTrade message = " .. tostring(res), 1)
      end
   
   return Operation, Price, trans_id
     
 end;
 
 --]]--

 

	
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
 
 
 