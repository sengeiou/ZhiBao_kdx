USE [BJG_DB]
GO
/****** Object:  StoredProcedure [dbo].[sp_CompensateInfo]    Script Date: 2020/5/15 14:58:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[sp_CompensateInfo]
@op nvarchar(20),
@CompensateNo nvarchar(200),
@ProductSecondLevelId int,
@ProductCode nvarchar(100),
@CompensateName nvarchar(100),
@Tel nvarchar(200),
@Fax nvarchar(100),
@CompensateType nvarchar(100),
@CompensatePeson nvarchar(100),
@Specifications nvarchar(100),
@Length nvarchar(100),
@CompensateStore nvarchar(100),
@CompensateDate datetime,
@Position nvarchar(100),
@ProblemDes nvarchar(max),
@ProblemOtherDes nvarchar(max),
@FindTime nvarchar(200),
@InstallationTime datetime,
@OtherDes nvarchar(max),
@DealerId int,
@StoreId int,
@Status int,
@ImageList nvarchar(max),
@AtchmentList nvarchar(max),
@result varchar(10) output
as
begin
      set @result='0'
      if @op='Add'
      begin
          if @CompensateNo is null or  @CompensateNo='' or @ProductSecondLevelId is null 
          or @ProductSecondLevelId=0 or @ProductCode is null or @ProductCode=''
          begin
               set @result='-1'  return
          end
          insert into CompensateInfo(CompensateNo,ProductSecondLevelId,ProductCode,CompensateName,
          Tel,Fax,CompensateType,CompensatePeson,Specifications,Length,CompensateStore,CompensateDate,
          Position,ProblemDes,ProblemOtherDes,FindTime,InstallationTime,OtherDes,DealerId,StoreId,Status,ImageList,AtchmentList)
          values(@CompensateNo,@ProductSecondLevelId,@ProductCode,@CompensateName,
          @Tel,@Fax,@CompensateType,@CompensatePeson,@Specifications,@Length,@CompensateStore,@CompensateDate,
          @Position,@ProblemDes,@ProblemOtherDes,@FindTime,@InstallationTime,@OtherDes,@DealerId,@StoreId,@Status,@ImageList,@AtchmentList)
          set @result=Convert(varchar(10),@@rowcount)
          return
      end
      if @op='Up'
      begin
          if @CompensateNo is null or  @CompensateNo='' or @ProductSecondLevelId is null 
          or @ProductSecondLevelId=0 or @ProductCode is null or @ProductCode=''
          begin
               set @result='-1'  return
          end
          update CompensateInfo set ProductSecondLevelId=@ProductSecondLevelId,ProductCode=@ProductCode,
          CompensateName=@CompensateName,Tel=@Tel,Fax=@Fax,CompensateType=@CompensateType,
          CompensatePeson=@CompensatePeson,Specifications=@Specifications,Length=@Length,
          CompensateStore=@CompensateStore,CompensateDate=@CompensateDate,Position=@Position,
          ProblemDes=@ProblemDes,ProblemOtherDes=@ProblemOtherDes,FindTime=@FindTime,
          InstallationTime=@InstallationTime,OtherDes=@OtherDes,@ImageList=ImageList,AtchmentList=@AtchmentList,Status=@Status
          where CompensateNo=@CompensateNo
          
          set @result=Convert(varchar(10),@@rowcount)
          return
         
      end
      if @op='Status'
      begin
          if @CompensateNo is null or  @CompensateNo='' 
          begin
               set @result='-1'  return
          end
          update CompensateInfo set Status=@Status   where CompensateNo=@CompensateNo
          set @result=Convert(varchar(10),@@rowcount)
          return
      end
      if @op='Del'
      begin
          if @CompensateNo is null or  @CompensateNo=''
          begin
               set @result='-1'  return
          end
          delete from CommentInfo where  CompensateNo=@CompensateNo
          delete from CompensateInfo where CompensateNo=@CompensateNo
          set @result=Convert(varchar(10),@@rowcount)
          return
      end
      if @op='GetPSDealer'
      begin
           if @DealerId=0
           begin
                set @result='-1'  return
           end
           select distinct a.ProductFirstLevelId,a.ProductSecondLevelId,b.ProductSecondLevelName from ProductInfo a left join dbo.ProductSecondLevelInfo b
		   on a.ProductSecondLevelId=b.ProductSecondLevelId
		   where DealerId=@DealerId
		   and Dealer_Flag=1
		   set @result=Convert(varchar(10),@@rowcount)
           return
      end

      
      if @op='GetPCDealer'
      begin
           if @DealerId=0 or @ProductSecondLevelId=0
           begin
                set @result='-1'  return
           end
           select a.*,b.ProductSecondLevelName from ProductInfo a left join dbo.ProductSecondLevelInfo b
		   on a.ProductSecondLevelId=b.ProductSecondLevelId
		   where a.DealerId=@DealerId and a.ProductSecondLevelId=@ProductSecondLevelId
		   and Dealer_Flag=1
		   set @result=Convert(varchar(10),@@rowcount)
           return
      end
       if @op='GetPSStore'
      begin
           if @StoreId=0
           begin
                set @result='-1'  return
           end
           select distinct a.ProductFirstLevelId,a.ProductSecondLevelId,b.ProductSecondLevelName from ProductInfo a left join dbo.ProductSecondLevelInfo b
		   on a.ProductSecondLevelId=b.ProductSecondLevelId
		   where StoreId=@StoreId and Store_Flag=1
		   set @result=Convert(varchar(10),@@rowcount)
           return
      end
      if @op='GetPCStore'
      begin
           if @StoreId=0 or @ProductSecondLevelId=0
           begin
                set @result='-1'  return
           end
        

	
		   select  ProductCode,sum(
			case when IsQuanCare=1 then 2.1 
				 when IsQuanCare=2 then 1.5 
				 when IsQuanCare=3 then 3.5  
				  else 0.75 end
			) as Total
			 into #tmp_F
		   from UserInfo
		   where ProductFirstLevelId=1 and ProductSecondLevelId=@ProductSecondLevelId
		   and StoreId=@StoreId
		   group by ProductCode
		  
		   select a.*,b.ProductSecondLevelName,(case when (a.Length-c.Total) is null  then a.Length  else (a.Length-c.Total) end)  as S_Total into  #data
		   from ProductInfo a left join dbo.ProductSecondLevelInfo b
		   on a.ProductSecondLevelId=b.ProductSecondLevelId
		   left join #tmp_F c
		   on a.ProductCode=c.ProductCode
		   where a.StoreId=@StoreId 
		   and a.ProductSecondLevelId=@ProductSecondLevelId
		   and Store_Flag=1 

		   update #data set S_Total=0 where S_Total is null
		   select * from #data  where S_Total>=0.75
			   

		   set @result=Convert(varchar(10),@@rowcount)
           return
      end
	  --侧后挡
	   if @op='GetPCStore_1'
      begin
           if @StoreId=0 or @ProductSecondLevelId=0
           begin
                set @result='-1'  return
           end

		   select  ProductCode,sum(1.5) as Total into #tmp_F_1
		   from UserInfo
		   where ProductFirstLevelId=2 and ProductSecondLevelId=@ProductSecondLevelId
		   and StoreId=@StoreId
		   group by ProductCode

		   select a.*,b.ProductSecondLevelName,(case when (a.Length-c.Total) is null  then a.Length  else (a.Length-c.Total) end)  as S_Total into  #data1
		   from ProductInfo a left join dbo.ProductSecondLevelInfo b
		   on a.ProductSecondLevelId=b.ProductSecondLevelId
		   left join #tmp_F_1 c
		   on a.ProductCode=c.ProductCode
		   where a.StoreId=@StoreId and a.ProductSecondLevelId=@ProductSecondLevelId
		   and Store_Flag=1 

		   update #data1 set S_Total=0 where S_Total is null

		   select * from #data1  where S_Total>=1.5

		   set @result=Convert(varchar(10),@@rowcount)
           return
      end
	  if @op='GetPCTStore'
      begin
           if @StoreId=0 or @ProductSecondLevelId=0
           begin
                set @result='-1'  return
           end

		   declare @bn int
		   set @bn=15
		   if Exists(select * from ProductSecondLevelInfo where ProductSecondLevelId=@ProductSecondLevelId and ProductFirstLevelId=6)
		   begin
			set @bn=21
		   end


		   select ProductCode,sum(meter) as Total into #tmp
		   from UserInfo
		   where  ProductSecondLevelId=@ProductSecondLevelId
		   and StoreId=@StoreId
		   group by ProductCode
		   having sum(meter)>=@bn

		   if Exists(select ProductCode from #tmp)
		   begin
			   select a.*,b.ProductSecondLevelName from ProductInfo a left join dbo.ProductSecondLevelInfo b
			   on a.ProductSecondLevelId=b.ProductSecondLevelId
			   where a.StoreId=@StoreId and a.ProductSecondLevelId=@ProductSecondLevelId
			   and Store_Flag=1
			   and ProductCode not in(select ProductCode from #tmp)
		   end
		   else
		   begin
		       select a.*,b.ProductSecondLevelName from ProductInfo a left join dbo.ProductSecondLevelInfo b
			   on a.ProductSecondLevelId=b.ProductSecondLevelId
			   where a.StoreId=@StoreId and a.ProductSecondLevelId=@ProductSecondLevelId
			   and Store_Flag=1
		   end
		   set @result=Convert(varchar(10),@@rowcount)
           return
      end
end


