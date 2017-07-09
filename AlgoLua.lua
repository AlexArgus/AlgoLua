
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
	  
	-- function table.contains(table, element)
		  -- for _, value in pairs(table) do
			  -- if value == element then
				  -- return true 
			  -- end 
		  -- end
		  -- return false
      -- end  		
	
	function GetTradeConditions(N, CT)
	
	    local N_ = N
		local CurrentTime_ = CT
	    local ATR_global_ = ATR_global
		local ATR_Level_  = ATR_Level
		local ATR_Condition_ = (ATR_global_ > ATR_Level_)
		
		--local SqrtPrice 
		--local EMA2Fast_last
		--local EMA2Slow_last
		--local EMADiff_last 
		--local Mlast         
		--local MLag
		--local Slast
		--local DiffMS_last   
		--local Blast
		--local BLag
		
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
		      GetMSB(N_); ------ ���������� ���������� ------
			   
		-- ��������� �������. ��������� ������ � ������� ��������� �������� �������� ������ List --------	   
		
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
		pushRightpopLeft('M', Mlast        )
		pushRightpopLeft('S', Slast        )	
		pushRightpopLeft('B', Blast        )
		
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
				
        return 	OpenLongCondition_, FirstCloseLongCondition_, 
		        OpenShortCondition_, FirstCloseShortCondition_			
				
	end -- GetTradeConditions(N, CT)
	
	--------- Calculate Average True Range (ATR) -------------------------
	
	function ATR(index)
			
			local index_ = index - 1
				
			if (index_ - last_index) > 0 then
				
				local H = data_source:H(index_    );
		        local C = data_source:C(index_ - 1);
		        local L = data_source:L(index_    );
		        local element_ = math.max( math.abs(H - L),
				                           math.abs(H - C),
										   math.abs(C - L))
										   
				if ( element_ > 0.005 * (H + L) ) then -- �� ��������� �� �������� "�������" ������ 1% �� ������� ����	
				    last_index = index_ 
					message('Too much element  ' .. element_)
					return 
				end 
				    					   
										   
				local TR_ = TR; 
				TR_:pushright(element_)
				local ATR_ = TR_:GetEMA2(_Period_ATR)   -- �� ��������� ������� list  ������� GetEMA2 ������ ����������� �������
				
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
						" ����� ��������� ����� " .. hour_ .. ":" .. min_ .. '\n')--  .. 
						-- "index  " .. index_);
						
				last_index = index_
				ATR_global = ATR_
				
            end				
			
	end;  -- ATR(index)
	
	
function OnInit()
  
    firm_id      = "SPBFUT000000";
	class        = "SPBFUT";
	sec          = "RIU7";
	ACCOUNT      = 'SPBFUT00802';                                          -- ������������� �����
	
	SEC_PRICE_STEP = getParamEx(class, sec, "SEC_PRICE_STEP").param_value; -- ����������� ��� ���� �����������
		
	    -- ������� �� ������ ������, ���������� � ���������� ���������� 
	
	if ( getNumberOf('futures_client_holding') ~= 0 )             
	    then position = getItem('futures_client_holding', 0).totalnet;
		else position = 0;
	end;	
	
	message('position ' .. tostring(position) );	
	  
	Balance       = 0;	                     -- ���������� ������������� ����� � �������� ������
	local ttime   = os.time();
	OrderOpenTime = ttime;                -- ������ ��� �������� ������
	PreviousTime  = ttime;               -- ��������� �������� ��� ������� OnParam;
	trans_id      = ttime;               -- ������ ��������� ����� ID ����������
	Flag          = 0;                       -- ���� ���������� ��������; 
	SessionStatus = 10;                      -- �������� ������������ ������ ��� SessionStatus == 0  � �������� / �������� ������; 
	  
	_q,_p,_m,_n = 3,9,13,26;
	
	_Period_ATR = 120;                       -- ATR �� 2 ��������� ���� --
		   
	
	_ShortTimeInterval, _LongTimeInterval = 37, 113  -- ������� EMA � ��������
	_MaxQuantityOfPositions              = 10;       -- ������������ ���������� ������� � ������� ����� �����������
	 
	
	P = GetMiddleSqrtPrice(class,sec)                -- ��������� ������� �������������� bid/ask
	
	ATR_Level = 0.0007 * P -- 70/100'000             -- ��������� ������� ATR ���� �������� ����� �����������.
	                                                 -- ��� ���� 80000, ������� ����� 60.
	
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
	
	TR               = List:new(); --��� ��������� ATR
	
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
	
	----- ������� ������ ��� ���������� ATR ------------------------
	
	data_source = CreateDataSource(class, sec, INTERVAL_M1); -- �������� ��������� ������ �� ����������� 'sec'	
	
	last_index = data_source:Size() - 1;

	if ( data_source ~= nil ) -- ����������� ��������� ������
		then
			message("�������� ������ �� ����������� " .. sec ..
         			" ������� ��������� \n\n" ..
                    "���������� ������ " .. last_index);
            IsRun = true;					
		else 
		    message("���-�� ����� �� ��� ... \n");
			IsRun = false;
	end;
	
	sleep(3000) -- ����� ����������� ��� ��������� ������ �� �����������
	
	--------- ��������� ������ ��� True Range -----------------------
	
	for index_ = (last_index - _Period_ATR), last_index do
	
	    local H = data_source:H(index_);
		local C = data_source:C(index_ - 1);
		local L = data_source:L(index_   );
		
		local element = math.max( math.abs(H - L), math.abs(H - C), math.abs(C - L) );
		
		local T_ = data_source:T(index_ )
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
	
	filePath = 'C:\\Users\\Alexandr\\Desktop\\Trading\\Lua\\'
	file = io.open(filePath .. 'MSBLog2.txt', 'w+');
	file:write('N' .. '\t' ..
	           'M60' .. '\t' .. 'M60Lag1' .. '\t'  .. 'M20' .. '\t' .. 'M20Lag1' .. '\t' ..
			   'S60' .. '\t' .. 'S20' .. '\t' .. 
			   'B60' .. '\t' ..  'B20' .. '\t' .. 'B20Lag1' .. '\t' .. 
			   'ATR' .. '\t' ..
	           'OLong' .. '\t' .. 'CLong' .. '\t' .. 'OShort' .. '\t' .. 'CShort' .. '\t' .. 
			   'Pos' .. '\t' .. 'Bal' .. '\t' .. 'Flag' .. '\t' .. 'Time' .. '\n');
	file:flush();
	
	Deals = io.open(filePath .. 'Deals2.txt', 'w+');
	Deals:write('Type' .. '\t' .. 'Bid' .. '\t' .. 'BidSize' .. '\t' ..
	            'Ask' .. '\t' .. 'AskSize' .. '\t' .. 'Position' .. '\t' ..
				'Time' .. '\n');
	Deals:flush();
	
	Timing = io.open(filePath .. 'Timing.txt', 'w+');
	Timing:write('hour' .. '\t' .. 'min' .. '\t' .. 'sec' .. '\t' .. 'ms' .. '\t' .. 'Position' .. '\t' .. 'Balance' .. '\t' ..
                 'Quantity' .. '\t' .. 'Flag' .. '\t' .. 'CBF0' .. '\t' .. 'CBF1' .. '\t' .. 'CBF2' .. '\t' .. 'CBF3' .. '\t' .. 
				 'NumberOforder' .. '\t' .. '\n');
	Timing:flush();
	
	Futures = io.open(filePath .. 'Futures.txt', 'w+');
	Futures:write('position' .. '\t' .. 'OB' .. '\t' .. 'OS' .. '\t' .. 'time' .. '\t' .. 'SessionStatus' .. '\t' .. 'F' .. '\n') 
	Futures:flush();
	
	sleep(2000); -- ����� ����������� ��� ��������� ������ �� �����������
	
end; -- OnInit
 
function  main()  

    ---------- Calculate ATR on Callback() -------------------------------
	
	data_source:SetUpdateCallback(ATR);
	
    ----------------------------------------------------------------------
	
    local  work_time = {100100, 135900, 140400, 154430, 160005, 184455, 190030, 234430} -- ��������� �������, ����� ����� ���������;
	
	local   STARTTIME    = getParamEx(class, sec, 'STARTTIME').param_value*1      -- STRING ������ �������� ������ 
	local	ENDTIME      = getParamEx(class, sec, 'ENDTIME').param_value*1        -- STRING ��������� �������� ������ 
	local	EVNSTARTTIME = getParamEx(class, sec, 'EVNSTARTTIME').param_value*1   -- STRING ������ �������� ������ 
	local	EVNENDTIME   = getParamEx(class, sec, 'EVNENDTIME').param_value*1     -- STRING ��������� �������� ������ 
	local	MONSTARTTIME = getParamEx(class, sec, 'MONSTARTTIME').param_value*1   -- STRING ������ �������� ������ 
	local	MONENDTIME   = getParamEx(class, sec, 'MONENDTIME').param_value*1     -- STRING ��������� �������� ������
	
	--[[
	message(    STARTTIME .. '\n'
	         .. ENDTIME .. '\n'
			 .. EVNSTARTTIME .. '\n'
			 .. EVNENDTIME .. '\n'
			 .. MONSTARTTIME .. '\n'
			 .. MONENDTIME .. '\n');
			 ]]--
	
    local  WarmUpTime   = os.time() + 5*60  -- �������� ������� 5 �����	
	local _WaitingTime = 60;	            -- ����� ���������� ������ � ��������

    while IsRun do -- SessionStatus == 0  �������� / �������� ������; 
	
	  local nowtime =	string.gsub(getInfoParam('SERVERTIME'),':','')*1;
	  local SessionStatus_2 = tonumber(getParamEx(class, sec, "status").param_value)
	
	
	  
	  if ( math.fmod(os.time() + 5, _LongTimeInterval) == 0 ) then
	      if     SessionStatus ==  0 then message('�������� / �������� ������')  
		  elseif SessionStatus ==  1 then message('������� �����������')
		  elseif SessionStatus ==  2 then message('���������� �����������')
		  elseif SessionStatus ==  3 then message('������� �������� �������')
		  elseif SessionStatus ==  4 then message('�������� �������,' .. '\n ����� ������ ���������')
		  elseif SessionStatus ==  5 then message('���������� �������� ������� ')
		  elseif SessionStatus == 10 then message('����� ��� �� �������')
	      end
		  message('\n' .. 'SessionStatus_2 =  ' .. SessionStatus_2);
      end		  
	
	  sleep(990)	
	
	--------------------- �������� � �������� ������� �� ��������� �������� -------------
	
      local timecond = 	( (nowtime > EVNSTARTTIME + 60) and  (nowtime < work_time[6]) ) or position ~= 0;   
	  
	  if ( (os.time() > WarmUpTime) and (SessionStatus_2 == 1) and timecond ) then  -- �������� ������� 5 ����� // ����� ���������� � ������ ��������!!!
	    
		local position_ = position
	    local BalanceFlag_ = (Balance == 0 and Flag == 0)
		local positionBalanceFlag_ = (position_ == 0 and BalanceFlag_ == true)
		
		if     ( OpenLongCondition  and (not FirstCloseLongCondition) and BalanceFlag_ )  then
		    MakeRecord('OpenLong', Deals);
		    Operation, Price, trans_id = Trade('B', _MaxQuantityOfPositions - position_);
			-- trans_id = FastTrade('B', _MaxQuantityOfPositions - position_)
		elseif ( FirstCloseLongCondition and position_ > 0 and BalanceFlag_ )  then
		    MakeRecord('CloseLong', Deals);
		    Operation, Price, trans_id = Trade('S', position_)
			-- trans_id = FastTrade('S', position_)
        elseif ( OpenShortCondition and position_ > 0 and BalanceFlag_)  then
		    MakeRecord('CloseLongByShort', Deals);
		    Operation, Price, trans_id = Trade('S', _MaxQuantityOfPositions + position_)
            -- trans_id = FastTrade('S', _MaxQuantityOfPositions + position_)			
		elseif ( OpenShortCondition and (not FirstCloseShortCondition) and BalanceFlag_ ) then
		    MakeRecord('OpenShort', Deals);
		    Operation, Price, trans_id = Trade( 'S', _MaxQuantityOfPositions - position_ )
			-- trans_id = FastTrade('S', _MaxQuantityOfPositions - position_)
		elseif ( FirstCloseShortCondition and position_ < 0 and BalanceFlag_ )  then
		    MakeRecord('CloseShort', Deals);
		    Operation, Price, trans_id = Trade('B', - position_)
			-- trans_id = FastTrade('B', - position_)
		elseif ( OpenLongCondition and position_ < 0 and BalanceFlag_ )  then
		    MakeRecord('CloseShortByLong', Deals);
		    Operation, Price, trans_id = Trade('B', _MaxQuantityOfPositions - position_)
			-- trans_id = FastTrade('B', _MaxQuantityOfPositions - position_)
		end;
		
		sleep(10)
		-------------------------------------------------
		-- ���� ��� ��������� ���������� �������. �������� � �������� ����� �������!
	    if (Flag ~= 0) then Flag = Flag - 1 end;
		-------------------------------------------------
	
	-- ����� ����������� ������ ���� WaitingTime = 1 ���, ����� ������� �����.
	-- � ������ ������������ ������, ����� ��������� ������� ���������� Market order (KillTransaction)
	
		local OrderOpenTime_ = OrderOpenTime;
		local DiffTime = os.difftime( os.time(), OrderOpenTime_ ); 	
	
		if Balance ~= 0 then 
		
			Flag = 2;
			
			if (DiffTime >= _WaitingTime) then
				local totalnet = math.abs(position);
				trans_id = RemoveTransaction(Operation, Price, totalnet);
			end;	
						
		end;
	
	----------- ��������� ��� �������� ������� ����� ������ ������ ----------------------
	
         -- local nowtime =	string.gsub(getInfoParam('SERVERTIME'),':','')*1;
		-- local cond1 = (nowtime > 184000) and (nowtime < 184450);
		local cond2 =  nowtime > EVNENDTIME - 60*10; -- ��������� ������� �� 10 ����� �� ����� ������	
		
		if ( cond2 ) and position ~= 0 then
		
			local Price = GetMiddleSqrtPrice(class,sec)
			local totalnet = math.abs(position);
			
			if position > 0 then
				trans_id = RemoveTransaction('S', Price, totalnet);
			elseif 	position < 0 then
				trans_id = RemoveTransaction('B', Price, totalnet);
			end;
			
			Flag = 2; 
			
		end;	
	
	  end;
	
    end; -- 1
   

end;

function  OnStop()
   IsRun  =  false;   
   file   :close();
   Deals  :close();
   Timing :close();
   Futures:close();
   data_source:Close();  
end;   --OnStop

function  OnOrder(order)
	   
	  numberOforder = order.order_num;
	  
	  local flag = order.flags
	  local CBF0 = CheckBit(flag, 0) -- �������/�� �������
	  local CBF1 = CheckBit(flag, 1) -- �����/�� �����
	  local CBF2 = CheckBit(flag, 2) -- �������/�������
	  local CBF3 = CheckBit(flag, 3) -- Limit/Market
	  local Balance_
	  
	  if CBF1 == 0 then
	      Balance_ = order.balance; 
	  else
       	  Balance_ = 0;
	  end;

      Balance = Balance_
      OrderOpenTime = os.time();	  
	  
	  -- if Balance_ > 0 then
	      -- Flag = 2;
	  -- end
	  
	  local TradeTime = order.datetime;
	  local Quantity_ =  order.qty;
	
	  Timing:write(TradeTime.hour .. '\t' ..
	               TradeTime.min  .. '\t' ..
			       TradeTime.sec  .. '\t' ..
				   TradeTime.ms   .. '\t' ..  
				   position       .. '\t' ..
				   Balance        .. '\t' ..
				   Quantity_      .. '\t' ..
				   Flag           .. '\t' .. 
				   CBF0           .. '\t' ..
				   CBF1           .. '\t'..
			       CBF2           .. '\t' ..
			       CBF3           .. '\t' ..
				   numberOforder  .. '\t' ..
				   'O'            .. '\n' 
				   )
       Flag = 2;				   
				   				    			  	  
end;

function  OnTrade(trade)

    Flag = 2;
	
    local TradeTime = trade.datetime;			 
	local flag = trade.flags;
	local Quantity = trade.qty; 
	 
	local CBF0 = CheckBit(flag, 0) -- �������/�� �������
	local CBF1 = CheckBit(flag, 1) -- �����/�� �����
	local CBF2 = CheckBit(flag, 2) -- �������/�������
	local CBF3 = CheckBit(flag, 3) -- Limit/Market
	
	Timing:write(TradeTime.hour            .. '\t' ..
	             TradeTime.min             .. '\t' ..
			     TradeTime.sec             .. '\t' ..
				 TradeTime.ms              .. '\t' ..				 
				 position                  .. '\t' ..
				 Balance                   .. '\t' ..
				 Quantity                  .. '\t' ..
				 Flag                      .. '\t' ..
				 tostring(CBF0)            .. '\t' ..
				 tostring(CBF1)            .. '\t' ..
			     tostring(CBF2)            .. '\t' ..
			     tostring(CBF3)            .. '\t' .. '\t' .. '\t' .. 'T' .. '\n'
				 )		
end;

function  OnFuturesClientHolding(fut_pos) 

   position = fut_pos.totalnet; -- �������� �������� � ���������� ����������
   
   local OB = fut_pos.openbuys;
   local OS = fut_pos.opensells;
   local StartPositions = fut_pos.startnet;
   SessionStatus = fut_pos.session_status; 
   
   if (OB ~= 0) or (OS ~= 0) then Flag = 2 end;	 

   local nowtime_ =	string.gsub(getInfoParam('SERVERTIME'),':','')*1;   
   
   Futures:write(position .. '\t' .. OB .. '\t' .. OS .. '\t' .. nowtime_ .. '\t' .. SessionStatus .. 'F' .. '\n')

 end;
 
function  OnParam(class,sec)
 
     local CurrentTime_ = os.time()
	 local LongTimeInterval_  = _LongTimeInterval   -- global constant
	 local ShortTimeInterval_ = _ShortTimeInterval  -- global constant
	 local PreviousTime_      = PreviousTime
	 local sec_ = sec
	 local ACCOUNT_ = ACCOUNT
	 local firmid_  = firm_id
	 
	 -- ��������� ������� �����������  � ���������� �������� �������� � �������� --
	 	 
	 if (CurrentTime_ - PreviousTime_) >= 1 then
	 
	      if math.fmod(CurrentTime_, LongTimeInterval_) == 0 then
		  
			 OpenLongCondition, FirstCloseLongCondition, 
			 OpenShortCondition, FirstCloseShortCondition =   
			 GetTradeConditions(60, CurrentTime_)
			 ------------------------------------
			 PreviousTime = CurrentTime_
		 end;
		 
		  if math.fmod(CurrentTime_, ShortTimeInterval_) == 0 then
		  
			 OpenLongCondition, FirstCloseLongCondition, 
			 OpenShortCondition, FirstCloseShortCondition =
			 GetTradeConditions(20, CurrentTime_)
			 ------------------------------------
			 PreviousTime = CurrentTime_
		 end
		 
		 ------------------------------------		 
	 
	 end;
	  
 end;

function  CheckBit(flags, bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= 'number' then error("��������������!!! Checkbit: 1-� �������� �� �����!"); end;
   if type(bit) ~= 'number' then error("��������������!!! Checkbit: 2-� �������� �� �����!"); end;
   local RevBitsStr  = ""; -- ������������ (����� �������) ��������� ������������� ��������� ������������� ����������� ����������� ����� (flags)
   local Fmod = 0; -- ������� �� �������
   local Go = true; -- ���� ������ �����
   while Go do
      Fmod = math.fmod(flags, 2); -- ������� �� �������
      flags = math.floor(flags/2); -- ��������� ��� ��������� �������� ����� ������ ����� ����� �� �������
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- ��������� ������ ������� �� �������
      if flags == 0 then Go = false; end; -- ���� ��� ��������� ���, ��������� ����
   end;
   -- ���������� �������� ����
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;

function  Trade(Operation, quantity)

        local quantity = quantity
		local trans_id = trans_id + 1;
		local Price;
		local Operation = Operation;
		local class = class;
	    local sec = sec;
	    local ACCOUNT = ACCOUNT;	    
	
       if     Operation == 'B' then		
		    Price = getParamEx(class, sec,   'bid').param_value*1  	
	   elseif Operation == 'S' then
		    Price = getParamEx(class, sec, 'offer').param_value*1 	
	   end; 	   

    message(Operation .. '  ' .. Price .. '  ' .. trans_id .. ' Quantity ' .. quantity)	   
  
   
   local Transaction={ 
   
	 ['TRANS_ID']   = tostring(trans_id),
	 ['ACTION']     = 'NEW_ORDER',
	 ['CLASSCODE']  = class,
	 ['SECCODE']    = sec,
	 ['OPERATION']  = Operation, 
	 ['TYPE']       = 'L',       
	 ['QUANTITY']   = tostring(quantity),      
	 ['ACCOUNT']    = ACCOUNT,
	 ['PRICE']      = tostring(Price)	  
   }			  			  
			     
   sendTransaction(Transaction) 
	
	return Operation, Price, trans_id
     
 end;

function  RemoveTransaction(Operation, Price, quantity)
       
	   local order_key = numberOforder;
	   local trans_id  = trans_id + 1;
	   local Operation = Operation;
	   local Price = Price;
	   local class = class;
	   local sec = sec;
	   local ACCOUNT = ACCOUNT;
   
	   local Transaction={	   
        ['TRANS_ID']   = tostring(trans_id),
        ['ORDER_KEY']  = tostring(order_key),
	    ['ACTION']     = 'KILL_ORDER',
        ['CLASSCODE']  = class,
	    ['SECCODE']    = sec,
	    ['OPERATION']  = Operation, 
	    ['TYPE']       = 'L', 
	    ['QUANTITY']   = tostring(quantity),
	    ['ACCOUNT']    = ACCOUNT,
	    ['PRICE']      = tostring(Price)
		}	
	
	   sendTransaction(Transaction); 
	   
	   if position ~= 0 then
	       local quantity_ = quantity
      	   trans_id = KillPosition(Operation, quantity_)
	   end
	   
	   return trans_id

 end; 
 
function  KillPosition(Operation, quantity)

    local quantity = quantity
	local trans_id  = trans_id + 1;
	local Operation = Operation;
	local class = class;
	local sec = sec;
	--local Price = GetMiddleSqrtPrice(class,sec);
	local Price;
	local ACCOUNT = ACCOUNT;
	local SEC_PRICE_STEP = SEC_PRICE_STEP;
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
		 ['QUANTITY']   = tostring(quantity),       
		 ['ACCOUNT']    = ACCOUNT,
		 ['PRICE']      = tostring(Price)
     }			  			  
			     
   sendTransaction(Transaction) 
   
   return trans_id
     
 end;
 
function  FastTrade(Operation, quantity)

    local quantity = quantity
	local trans_id  = trans_id + 1;
	local Operation = Operation;
	local class = class;
	local sec = sec;
	--local Price = GetMiddleSqrtPrice(class,sec);
	local Price;
	local ACCOUNT = ACCOUNT;
	local SEC_PRICE_STEP = SEC_PRICE_STEP;
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
		 ['QUANTITY']   = tostring(quantity),       
		 ['ACCOUNT']    = ACCOUNT,
		 ['PRICE']      = tostring(Price)
     }			  			  
			     
   sendTransaction(Transaction) 
   
   return trans_id
     
 end;

 

	
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
 
 
 