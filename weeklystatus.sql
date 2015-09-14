Declare
@sdate DATE = '2013-12-3'

Declare
@edate DATE = '2014-1-23'


SELECT row_number() over (order by o.PProductType,datepart(yy,o.CreateTime),datepart(wk,o.CreateTime)) as rowNum,
'ProductType' = case   
	when o.PProductType = 1 then 'Currency'
	when o.PProductType = 2 then 'Item'
	when o.PProductType = 3 then 'Account'
	when o.PProductType = 4 then 'Power_leveling'
	when o.PProductType = 5 then 'Game Guide'
	when o.PProductType = 6 then 'TimeCard'
	when o.PProductType = 7 then 'Other' end,
	sum(convert(decimal(18,2),case when pl.BuyerMoneyType='CNY' 
then pl.buyerpaidprice/(pl.PaidExchangeRate/100) else pl.buyerpaidprice end)) as OrderValue,
count(o.OrderId) as OrderVolume,
'Average'= sum(convert(decimal(18,2),case when pl.BuyerMoneyType='CNY' 
then pl.buyerpaidprice/(pl.PaidExchangeRate/100) else pl.buyerpaidprice end))/count(o.OrderId),
datepart(wk,o.CreateTime) as WeekNum,datepart(yy,o.CreateTime) as YearNum
  into #mreportp1
  FROM [PlayerAuctions].[dbo].[Order] o
  join [PlayerAuctions].[dbo].[PaymentLog] pl on pl.PaymentId=o.PaymentId
  where o.OrderStatus in (1,2,3,4,5,6)
  and o.CreateTime>=dateadd(day,1-datepart(WEEKDAY,@sdate),@sdate)
  and o.CreateTime<=dateadd(day,1-datepart(WEEKDAY,@edate)+7,@edate)
  group by o.PProductType,datepart(wk,o.CreateTime),datepart(yy,o.CreateTime)

SELECT	row_number() over (order by o.PProductType,datepart(yy,o.CreateTime),datepart(wk,o.CreateTime)) as rowNum6,
sum(convert(decimal(18,2),case when pl.BuyerMoneyType='CNY' 
then pl.buyerpaidprice/(pl.PaidExchangeRate/100) else pl.buyerpaidprice end)) as OrderValue6,
count(o.OrderId) as OrderVolume6
into #mreportp2
  FROM [PlayerAuctions].[dbo].[Order] o
  join [PlayerAuctions].[dbo].[PaymentLog] pl on pl.PaymentId=o.PaymentId
  where o.OrderStatus in (1,2,3,4,5,6)
  and o.CreateTime>=dateadd(day,1-datepart(WEEKDAY,dateadd(mm,-6,@sdate)),dateadd(mm,-6,@sdate))
  and o.CreateTime<=dateadd(day,8-datepart(weekday,
  dateadd(wk,case when datepart(wk,@sdate) in (1,53) or datepart(yy,@sdate)<datepart(yy,@edate) then
datediff(wk,dateadd(day,1-datepart(WEEKDAY,@sdate),@sdate),dateadd(day,1-datepart(WEEKDAY,@edate)+7,@edate))
else
datediff(wk,dateadd(day,1-datepart(WEEKDAY,@sdate),@sdate),dateadd(day,1-datepart(WEEKDAY,@edate)+7,@edate))-1 end,dateadd(mm,-6,@sdate)
)),dateadd(wk,case when datepart(wk,@sdate) in (1,53) or datepart(yy,@sdate)<datepart(yy,@edate) then
datediff(wk,dateadd(day,1-datepart(WEEKDAY,@sdate),@sdate),dateadd(day,1-datepart(WEEKDAY,@edate)+7,@edate))
else
datediff(wk,dateadd(day,1-datepart(WEEKDAY,@sdate),@sdate),dateadd(day,1-datepart(WEEKDAY,@edate)+7,@edate))-1 end,dateadd(mm,-6,@sdate)
))
  group by o.PProductType,datepart(wk,o.CreateTime),datepart(yy,o.CreateTime)

SELECT	row_number() over (order by o.PProductType,datepart(yy,o.CreateTime),datepart(wk,o.CreateTime)) as rowNum12,
sum(convert(decimal(18,2),case when pl.BuyerMoneyType='CNY' 
then pl.buyerpaidprice/(pl.PaidExchangeRate/100) else pl.buyerpaidprice end)) as OrderValue12,
count(o.OrderId) as OrderVolume12
into #mreportp3
  FROM [PlayerAuctions].[dbo].[Order] o
  join [PlayerAuctions].[dbo].[PaymentLog] pl on pl.PaymentId=o.PaymentId
  where o.OrderStatus in (1,2,3,4,5,6)
  and o.CreateTime>=dateadd(day,1-datepart(WEEKDAY,dateadd(yy,-1,@sdate)),dateadd(yy,-1,@sdate))
  and o.CreateTime<=dateadd(day,1-datepart(WEEKDAY,dateadd(yy,-1,@edate))+7,dateadd(yy,-1,@edate))
  group by o.PProductType,datepart(wk,o.CreateTime),datepart(yy,o.CreateTime)

  Select YearNum,WeekNum,ProductType,OrderValue,OrderVolume,Average,OrderValue6,OrderVolume6,OrderValue12,OrderVolume12
  from #mreportp1
  left join #mreportp2 on rowNum6=rowNum
  left join #mreportp3 on rowNum12=rowNum 
  order by rowNum
  drop table #mreportp1,#mreportp2,#mreportp3
