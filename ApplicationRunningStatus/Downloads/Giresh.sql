USE [master]
GO
/****** Object:  Database [Beumer_Group3]    Script Date: 11-04-2023 16:21:42 ******/
CREATE DATABASE [Beumer_Group3]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Beumer_Group3', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Beumer_Group3.mdf' , SIZE = 8256KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Beumer_Group3_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Beumer_Group3_log.ldf' , SIZE = 1088KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Beumer_Group3] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Beumer_Group3].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Beumer_Group3] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Beumer_Group3] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Beumer_Group3] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Beumer_Group3] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Beumer_Group3] SET ARITHABORT OFF 
GO
ALTER DATABASE [Beumer_Group3] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Beumer_Group3] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Beumer_Group3] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Beumer_Group3] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Beumer_Group3] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Beumer_Group3] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Beumer_Group3] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Beumer_Group3] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Beumer_Group3] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Beumer_Group3] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Beumer_Group3] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Beumer_Group3] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Beumer_Group3] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Beumer_Group3] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Beumer_Group3] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Beumer_Group3] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Beumer_Group3] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Beumer_Group3] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Beumer_Group3] SET RECOVERY FULL 
GO
ALTER DATABASE [Beumer_Group3] SET  MULTI_USER 
GO
ALTER DATABASE [Beumer_Group3] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Beumer_Group3] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Beumer_Group3] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Beumer_Group3] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Beumer_Group3', N'ON'
GO
USE [Beumer_Group3]
GO
/****** Object:  StoredProcedure [dbo].[Date_To_Table]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Date_To_Table] 

  @ColumnToPivot  NVARCHAR(255),
  @ListToPivot    NVARCHAR(255),
  @YEAR VARCHAR(30)
AS
BEGIN
 
DECLARE @minDate_Str VARCHAR(50)='01-01-'+@year
DECLARE @maxDate_Str VARCHAR(50)='31-12-'+@year
  SET @YEAR = N'
    SELECT * FROM (
      SELECT
        [Datestring],
        [DateNamestring],
        [Marks]
      FROM @YEAR
    ) DateStringResults,DateNamestringResults
    PIVOT (
      ([DateString])
      FOR ['+@ColumnToPivot+']
      IN (
        '+@ListToPivot+'
      )
    ) AS PivotTable
  ';
  end 


GO
/****** Object:  StoredProcedure [dbo].[GetTotalByDays]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTotalByDays] 
(
    @StartDate datetime,
    @EndDate datetime
)
AS 
BEGIN
    SELECT S.year as [Year],
    MONTH(S.date) as [Month],
    SUM(S.Value) as [Value]
    FROM Sale S
    WHERE S.date BETWEEN @StartDate and @EndDate
    GROUP BY S.year, MONTH(S.date) 
    ORDER BY [Year], [Month] 
END


EXEC dbo.GetTotalByDays @StartDate = '01/01/2013', @EndDate = '01/01/2014'


GO
/****** Object:  StoredProcedure [dbo].[sp_ExtendProjectDate]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ExtendProjectDate]    
(@ProjectName NVARCHAR(max),@StartDate date, @EndDate date, @OldEndDate date, @EmpId nvarchar(100))
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     declare @TempTable table ( MonthName1 nvarchar(50) , YearName1  nvarchar(50))

     Declare @ProjectID nvarchar(max) 
     set @ProjectID = (select ProjectID from tblProject where ProjectCode=+ @ProjectName)
     --declare @startDateN DATE = (select ProjectEndDate from tblProject where ProjectID=+@ProjectID)
     declare @startDateN DATE = @OldEndDate
--print @startDateN

     if(@EndDate = @startDateN)
     Begin
--print 'Step 1'
         Print 'No Change.'
     End

     if(@EndDate > @startDateN)
     BEGIN
--print 'Step 2'
         declare @start DATE = DATEADD(month,1,@startDateN)
         declare @end DATE = @EndDate
         ;with months (date)
         AS
         (
              SELECT @start
              UNION ALL
              SELECT DATEADD(month,1,date)
              from months
              where DATEADD(month,1,date)<=@end
         )
         insert into @TempTable
         select Datename(month,date),Datename(YEAR,date)  from months
         --select * from @TempTable
         -- DATA TO BE ADDED FOR SPECIFIC ProjectID (@ProjectID).

         --declare @TempTable1 table ( EmployeeID nvarchar(50))
         --insert into @TempTable1
         --select Distinct EmployeeID from tblMonthData where ProjectID=+@ProjectID

         --DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         --LOCAL FORWARD_ONLY FAST_FORWARD                  --optimising for speed and memory
         --FOR SELECT  EmployeeID FROM @TempTable1
         --DECLARE @EmployeeID nvarchar(50)
         --OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
         --WHILE @@FETCH_STATUS=0
         --   BEGIN
--print 'Step 2.1'
                       DECLARE idCursor1 CURSOR                     --iterates over IDs present in the data set
                       LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                       FOR SELECT  MonthName1,YearName1 FROM @TempTable
                       DECLARE @MonthName1 nvarchar(50),@YearName1 nvarchar(50)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @MonthName1,@YearName1
                       WHILE @@FETCH_STATUS=0
                       BEGIN
--print 'Step 2.2'
--print 'MonthName : ' + @MonthName1 + '& YearName : '+@YearName1 + '& ProjectID : '+@ProjectID + '& EmployeeID : '+@EmployeeID

                       IF ((select count(*) from tblMonthData where PresentMonth=+@MonthName1 and  PresentYear=+@YearName1 and  ProjectID=+@ProjectID and EmployeeID=+@EmpId ) = 0)
                       BEGIN
                          insert into tblMonthData(EmployeeID,ProjectID,PresentMonth,PresentYear,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],
                       [18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
                       values(@EmpId,@ProjectID,@MonthName1,@YearName1,'P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P')
                       END

                       FETCH NEXT FROM idCursor1 INTO @MonthName1,@YearName1
                       END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                  
         --       FETCH NEXT FROM idCursor INTO @EmployeeID
         --   END
         --CLOSE idCursor
         --DEALLOCATE idCursor

         Declare @CountDays int
         declare @i int =1
         set @CountDays= (SELECT DATEDIFF(DAY, @startDateN, @EndDate))
--print 'COUNT DAYS : '  + cast(@CountDays as nvarchar(20))
         Declare @StartDate123 date = @EndDate
         while(@i <= @CountDays)
         begin
--print @StartDate123
--print DATENAME(dw,@StartDate123)
         if(DATENAME(dw,@StartDate123) = 'Sunday' or  DATENAME(dw,@StartDate123) = 'Saturday')
         begin
--print 'Step 101'
                  if((select count(*) from tblHolidayCalander where DateOfHoliday=+@StartDate123 )=0)
                  begin
--print 'Step 102'
                  insert into tblHolidayCalander(DateOfHoliday,DayOfWeek1) values(@StartDate123,DATENAME(dw,@StartDate123))
                  end
         end
         set @StartDate123=DATEADD(day,-1,@StartDate123)
         set @i = @i+1
--print @i
         end

     END

     if(@EndDate < @startDateN)
     Begin
--print 'Step 3'
         declare @start1 DATE = DATEADD(month,1,@EndDate)
         declare @end1 DATE = @startDateN
         ;with months (date)
         AS
         (
              SELECT @start1
              UNION ALL
              SELECT DATEADD(month,1,date)
              from months
              where DATEADD(month,1,date)<=@end1
         )
         insert into @TempTable
         select Datename(month,date),Datename(YEAR,date)  from months
         --select * from @TempTable
         -- DATA TO BE DELETED FOR SPECIFIC ProjectID (@ProjectID).

         DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  MonthName1,YearName1 FROM @TempTable
         DECLARE @MonthName2 nvarchar(50) , @YearName2  nvarchar(50)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @MonthName2,@YearName2
         WHILE @@FETCH_STATUS=0
              BEGIN
--print 'STEP 1'
                  declare @SqlQuery nvarchar(300)
                  set @SqlQuery = 'delete from tblMonthData where PresentMonth= '''+ @MonthName2 + ''' and  PresentYear= '+ @YearName2 + ' and  ProjectID= '+ @ProjectID + ' and  EmployeeID= '+ @EmpId 
                  --print @SqlQuery
                  EXECUTE sp_executesql @SqlQuery
                  FETCH NEXT FROM idCursor INTO @MonthName2,@YearName2
              END
         CLOSE idCursor
         DEALLOCATE idCursor
     End

--update tblProject set ProjectEndDate=@EndDate where ProjectID=+@ProjectID
     EXEC spInsert_SetHoliday;
COMMIT TRANSACTION
END TRY

BEGIN CATCH
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorMessage NVARCHAR(4000)

-- Get error text
SET @ErrorSeverity = ERROR_SEVERITY()
SET @ErrorState = ERROR_STATE()
SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

IF (XACT_STATE() = -1)
BEGIN
     ROLLBACK TRANSACTION;
END

IF (XACT_STATE() = 1)
BEGIN
     COMMIT TRANSACTION;
END

RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

END CATCH














GO
/****** Object:  StoredProcedure [dbo].[sp_insertupdate]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insertupdate] 
(
 @Recid  bigint,
 @EmployeeID   VARCHAR(max),
 @EmployeeName     VARCHAR(max),
 @PositionTitle     VARCHAR(max),
 @Department      VARCHAR(max),
 @DirectSupervisor VARCHAR(max),
 @CostCentre      VARCHAR(max),
 @OperatorName       VARCHAR(max),
 @LastEditTime      datetime,
 @StatementType NVARCHAR(20) = '')
										
AS
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN
            INSERT INTO tblEmployee
                        (Recid,
                         EmployeeID,
                         EmployeeName,
                         PositionTitle,
                         Department,
						 DirectSupervisor,
						 CostCentre,
						 OperatorName,
						 LastEditTime)

            VALUES     ( @Recid,
                         @EmployeeID,
                         @EmployeeName,
                         @PositionTitle,
                         @Department,
						 @DirectSupervisor,
						 @CostCentre,
						 @OperatorName,
						 @LastEditTime)
        END

      IF @StatementType = 'Select'
        BEGIN
            SELECT *
            FROM  tblEmployee
        END

      IF @StatementType = 'Update'
        BEGIN
            UPDATE tblEmployee
            SET          Recid = @Recid,
                         EmployeeID = @EmployeeID,
                         EmployeeName = @EmployeeName,
                         PositionTitle = @PositionTitle,
                         Department = @Department,
						 DirectSupervisor = @DirectSupervisor,
						 CostCentre = @CostCentre,
						 OperatorName = @OperatorName,
						 LastEditTime = @LastEditTime
            WHERE  RecId = @Recid
        END
      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM tblEmployee
            WHERE  RecId = @Recid
        END
  END


GO
/****** Object:  StoredProcedure [dbo].[sp_UnassignProject]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UnassignProject]    
(@ProjectName NVARCHAR(max), @UnassingedStartDate date, @EndDate date, @EmpId nvarchar(100))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @TempTable table ( MonthName1 nvarchar(50) , YearName1  nvarchar(50))

     Declare @ProjectID nvarchar(max)
     set @ProjectID = (select ProjectID from tblProject where ProjectCode=+ @ProjectName)
--print 'PID : ' +  @ProjectID

         declare @start DATE = @UnassingedStartDate
         declare @end DATE = @EndDate

         ;with months (date)
         AS
         (
              SELECT @start
              UNION ALL
              SELECT DATEADD(month,1,date)
              from months
              where DATEADD(month,1,date)<=DATEADD(month, 1, @end)
         )
         insert into @TempTable
         select Datename(month,date),Datename(YEAR,date)  from months
     
         select * from @TempTable

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  MonthName1,YearName1 FROM @TempTable
         DECLARE @MonthName1 nvarchar(50) , @YearName1  nvarchar(50)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @MonthName1,@YearName1
         WHILE @@FETCH_STATUS=0
              BEGIN
--print 'STEP 1'
                  declare @SqlQuery nvarchar(300)
                  set @SqlQuery = 'delete from tblMonthData where PresentMonth= '''+ @MonthName1 + ''' and  PresentYear= '+ @YearName1 + ' and  ProjectID= '+ @ProjectID + ' and  EmployeeID= '+ @EmpId 
                  --print @SqlQuery
                  EXECUTE sp_executesql @SqlQuery
                  FETCH NEXT FROM idCursor INTO @MonthName1,@YearName1
              END
         CLOSE idCursor
         DEALLOCATE idCursor



COMMIT TRANSACTION
END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spDelete_C_PH_Type]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDelete_C_PH_Type]    
(@RecId bigint)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
              declare @EmployeeID nvarchar(50) =(select EmployeeID from tblEmpHoliday where RecId=@RecId)
              declare @HolidayStartDate DATE = (select HolidayStartDate from tblEmpHoliday where RecId=@RecId)
              declare @HolidayEndDate DATE = (select HolidayEndDate from tblEmpHoliday where RecId=@RecId)

			  declare @NumOfDays int
			 set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
			 set @NumOfDays= @NumOfDays+1
			 print @NumOfDays

              declare @count int set @count=0
              while(@count < @numOfDays)
              begin
              print @HolidayStartDate
              declare @SqlQuery1 nvarchar(200)
                       declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
                            set @month1=(select DATENAME(MM,@HolidayStartDate))
                            set @year1=(select DATENAME(YYYY,@HolidayStartDate))
                            set @Day1=(select DATENAME(DD,@HolidayStartDate))
                       if(@EmployeeID != 000000)
                       begin
                            set @SqlQuery1='update tblMonthData set ['+@Day1+']=''P'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO'''+' and EmployeeID ='+cast(@EmployeeID as nvarchar(50))
                            print @SqlQuery1
                            execute sp_sqlexec @SqlQuery1
                       end
                       else if(@EmployeeID = '000000')
                       begin
                       print 'step 6'
                            set @SqlQuery1='update tblMonthData set ['+@Day1+']=''P'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ( ['+@Day1+'] =''PH'''+' or ['+@Day1+'] =''C'')'
                            print @SqlQuery1
                            execute sp_sqlexec @SqlQuery1

                            delete from tblHolidayCalander where DateOfHoliday=@HolidayStartDate

                       end

              set @HolidayStartDate=(select DATEADD(day,1, @HolidayStartDate))
              set @count=@count+1
              end

              delete from tblEmpHoliday where RecId=@RecId
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spDelete_ProjectTask]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDelete_ProjectTask]
(@RecID nvarchar(max),@EmpID NVARCHAR(max),@ProjectCode NVARCHAR(max),@PMonth NVARCHAR(max),@PYear NVARCHAR(max),@Task nvarchar(max))    
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY

     declare @RID int 
     set @RID= (select ProjectID from tblTask where RecID=+@RecID)

     declare @Count1 int
     set @Count1=(select count(*) from tblMonthData where EmployeeID=+cast(@EmpID as nvarchar(100)) and PresentMonth like '%'+cast(@PMonth as nvarchar(100))+'%' and PresentYear like '%'+cast(@PYear as nvarchar(100))+'%' and ProjectID like '%'+cast(@RID as nvarchar(100))+'%') 

     if(@Count1 > 1)
     begin
     delete from tblTask where RecID=+@RecID
     delete from tblMonthData where EmployeeID=+cast(@EmpID as nvarchar(100)) and PresentMonth like '%'+cast(@PMonth as nvarchar(100))+'%' and PresentYear like '%'+cast(@PYear as nvarchar(100))+'%' and ProjectID like '%'+cast(@RID as nvarchar(100))+'%' and Task like '%'+@Task+'%'   
     end
     else if(@Count1 = 1)
     begin
     delete from tblTask where RecID=+@RecID
    update tblMonthData set Task=null where EmployeeID=+cast(@EmpID as nvarchar(100)) and PresentMonth like '%'+cast(@PMonth as nvarchar(100))+'%' and PresentYear like '%'+cast(@PYear as nvarchar(100))+'%' and ProjectID like '%'+cast(@RID as nvarchar(100))+'%' and Task like '%'+@Task+'%'   
     end
     
     EXEC spInsert_SetHoliday;

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_CommonHoliday]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_CommonHoliday]    
(@HolidayStartDate date, @HolidayEndDate date, @Reason NVARCHAR(max),@HolidayType nvarchar(50), @NumberOfDays int)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     declare @editdate datetime
     select @editdate = (select GETDATE())
         
     INSERT INTO tblEmpHoliday 
(EmployeeID,EmployeeName,Department,HolidayStartDate,HolidayEndDate,Reason,NumberOfDays,LastEditTime)
     VALUES
('000000','000000','000000',@HolidayStartDate,@HolidayEndDate,@Reason,@NumberOfDays,@editdate)

     declare @RecId int
     set @RecId=(SELECT SCOPE_IDENTITY());

         if(@HolidayType = 'Public Holiday')
         begin
         set @HolidayType ='PH'
         end
         else if(@HolidayType = 'Common (not PH)')
         begin
         set @HolidayType ='C'
         end
     
     -- UPDATE tblMonthData and Insert REASON between chosen date. 
     DECLARE @TempTable TABLE (  DateOfHoliday      date)
     set @HolidayStartDate=(select HolidayStartDate from tblEmpHoliday where RecId=@RecId)
     set @HolidayEndDate=(select HolidayEndDate from tblEmpHoliday where RecId=@RecId)
     declare @NumOfDays int
     set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
     set @NumOfDays= @NumOfDays+1
     --print @NumOfDays


     DECLARE @date_value INT;
     SET @date_value = 0;

     WHILE @date_value < @NumOfDays
     BEGIN
         Insert into @TempTable(DateOfHoliday) values(DATEADD(day,@date_value , @HolidayStartDate))
        SET @date_value = @date_value + 1;
     END;
     --select * from @TempTable
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday FROM @TempTable
     DECLARE @DateOfHoliday date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
              set @month=(select DATENAME(MM,@DateOfHoliday))
              set @year=(select DATENAME(YYYY,@DateOfHoliday))
              set @Day=(select DATENAME(DD,@DateOfHoliday))

              declare @SqlQuery nvarchar(200)
              set @SqlQuery='update tblMonthData set ['+@Day+']='''+@HolidayType+''' where PresentMonth='''+@month+''' and  PresentYear= '+@year +'and ['+@Day+'] !=''WO'''
              --print @SqlQuery
              execute sp_sqlexec @SqlQuery


                            declare @result int
                            select * from tblHolidayCalander where DateOfHoliday=@DateOfHoliday
                            set @result=(SELECT @@ROWCOUNT)
                            IF (@result = 0)
                            insert into  tblHolidayCalander (DateOfHoliday,DayOfWeek1) values(@DateOfHoliday,@HolidayType)

              FETCH NEXT FROM idCursor INTO @DateOfHoliday
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_CommonHolidayUpdate]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_CommonHolidayUpdate]    
(@HolidayStartDate datetime, @HolidayEndDate datetime, @Reason NVARCHAR(max),@HolidayType nvarchar(50),@NumberOfDays int,@RecId bigint)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     -- UPDATE previous holiday as PRESENT
     --declare @RecId bigint
     --set @RecId=38
     declare @HolidayStartDate1 date , @HolidayEndDate1 date
     DECLARE @TempTable TABLE (  DateOfHoliday      date)
     set @HolidayStartDate1=(select HolidayStartDate from tblEmpHoliday where RecId=@RecId)
     set @HolidayEndDate1=(select HolidayEndDate from tblEmpHoliday where RecId=@RecId)
     declare @NumOfDays int
     set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate1, @HolidayEndDate1) AS DateDiff)
     set @NumOfDays= @NumOfDays+1
     --print @NumOfDays

     DECLARE @date_value INT;
     SET @date_value = 0;

     WHILE @date_value < @NumOfDays
     BEGIN
         Insert into @TempTable(DateOfHoliday) values(DATEADD(day,@date_value , @HolidayStartDate1))
        SET @date_value = @date_value + 1;
     END;

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday FROM @TempTable
     DECLARE @DateOfHoliday date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
              set @month=(select DATENAME(MM,@DateOfHoliday))
              set @year=(select DATENAME(YYYY,@DateOfHoliday))
              set @Day=(select DATENAME(DD,@DateOfHoliday))

              declare @SqlQuery nvarchar(200)
              set @SqlQuery='update tblMonthData set ['+@Day+']=''P'' where PresentMonth='''+@month+''' and  PresentYear= '+@year +'and ['+@Day+'] !=''WO'''
              --print @SqlQuery
              execute sp_sqlexec @SqlQuery

                            declare @result int
                            select * from tblHolidayCalander where DateOfHoliday=@DateOfHoliday
                            set @result=(SELECT @@ROWCOUNT)
                            IF (@result = 1)
                            delete from tblHolidayCalander where DateOfHoliday=@DateOfHoliday

              FETCH NEXT FROM idCursor INTO @DateOfHoliday
         END
     CLOSE idCursor
     DEALLOCATE idCursor
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     declare @editdate datetime,@EmployeeID nvarchar(20)
     select @editdate = (select GETDATE())

     set @EmployeeID= (SELECT EmployeeID from tblEmpHoliday where RecId=@RecId)
     
     update tblEmpHoliday set HolidayStartDate=@HolidayStartDate,HolidayEndDate=@HolidayEndDate,Reason=@Reason,NumberOfDays=@NumberOfDays,LastEditTime=@editdate where RecId=@RecId 
         
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     -- UPDATE tblMonthData and Insert REASON between chosen date. 

     if(@HolidayType = 'Public Holiday')
         begin
         set @HolidayType ='PH'
         end
         else if(@HolidayType = 'Common (not PH)')
         begin
         set @HolidayType ='C'
         end  

     DECLARE @TempTable1 TABLE (  DateOfHoliday1         date)
     declare @NumOfDays1 int
     set @NumOfDays1 = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
     set @NumOfDays1= @NumOfDays1+1
     --print @NumOfDays1


     DECLARE @date_value1 INT;
     SET @date_value1 = 0;

     WHILE @date_value1 < @NumOfDays1
     BEGIN
         Insert into @TempTable1(DateOfHoliday1) values(DATEADD(day,@date_value1 , @HolidayStartDate))
        SET @date_value1 = @date_value1 + 1;
     END;
     --select * from @TempTable
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday1 FROM @TempTable1
     DECLARE @DateOfHoliday1 date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday1
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
              set @month1=(select DATENAME(MM,@DateOfHoliday1))
              set @year1=(select DATENAME(YYYY,@DateOfHoliday1))
              set @Day1=(select DATENAME(DD,@DateOfHoliday1))

              declare @SqlQuery1 nvarchar(200)
              set @SqlQuery1='update tblMonthData set ['+@Day1+']='''+@HolidayType+''' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1 +' and ['+@Day1+'] !=''WO'''
              --print @SqlQuery1
              execute sp_sqlexec @SqlQuery1

                            declare @result1 int
                            select * from tblHolidayCalander where DateOfHoliday=@DateOfHoliday1
                            set @result1=(SELECT @@ROWCOUNT)
                            IF (@result1 = 0)
                            insert into  tblHolidayCalander (DateOfHoliday,DayOfWeek1) values(@DateOfHoliday,@HolidayType)

              FETCH NEXT FROM idCursor INTO @DateOfHoliday1
         END
     CLOSE idCursor
     DEALLOCATE idCursor
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_HolidayCalander]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_HolidayCalander]    
(@DateOfHoliday datetime, @DayOfWeek1 NVARCHAR(50))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     declare @editdate datetime
     select @editdate = (select GETDATE())
         
     INSERT INTO tblHolidayCalander 
     (DateOfHoliday,DayOfWeek1)
     VALUES
     (@DateOfHoliday,@DayOfWeek1)

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_HolidayMaster]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_HolidayMaster]    
(@EmployeeID NVARCHAR(max),@EmployeeName NVARCHAR(max),@HolidayStartDate date, @HolidayEndDate date, @Reason NVARCHAR(max), @NumberOfDays int)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     declare @editdate datetime
     select @editdate = (select GETDATE())
         
     INSERT INTO tblEmpHoliday 
(EmployeeID,EmployeeName,HolidayStartDate,HolidayEndDate,Reason,NumberOfDays,LastEditTime)
     VALUES
(@EmployeeID,@EmployeeName,@HolidayStartDate,@HolidayEndDate,@Reason,@NumberOfDays,@editdate)

     declare @RecId int
     set @RecId=(SELECT SCOPE_IDENTITY());
     
     -- UPDATE tblMonthData and Insert REASON between chosen date. 
     DECLARE @TempTable TABLE (  DateOfHoliday      date)
     --declare @EmployeeID NVARCHAR(max) , @HolidayStartDate date , @HolidayEndDate date
     --set @EmployeeID='707520'
     set @HolidayStartDate=(select HolidayStartDate from tblEmpHoliday where RecId=@RecId)
     set @HolidayEndDate=(select HolidayEndDate from tblEmpHoliday where RecId=@RecId)
     declare @NumOfDays int
     set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
     set @NumOfDays= @NumOfDays+1
     print @NumOfDays


     DECLARE @date_value INT;
     SET @date_value = 0;

     WHILE @date_value < @NumOfDays
     BEGIN
         Insert into @TempTable(DateOfHoliday) values(DATEADD(day,@date_value , @HolidayStartDate))
        SET @date_value = @date_value + 1;
     END;
     --select * from @TempTable
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday FROM @TempTable
     DECLARE @DateOfHoliday date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
              set @month=(select DATENAME(MM,@DateOfHoliday))
              set @year=(select DATENAME(YYYY,@DateOfHoliday))
              set @Day=(select DATENAME(DD,@DateOfHoliday))

              declare @SqlQuery nvarchar(200)
              set @SqlQuery='update tblMonthData set ['+@Day+']=''A'' where PresentMonth='''+@month+''' and  PresentYear= '+@year +' and  EmployeeID='+ @EmployeeID +'and ['+@Day+'] !=''WO''' +'and ['+@Day+'] !=''C'''
              print @SqlQuery
              execute sp_sqlexec @SqlQuery

              FETCH NEXT FROM idCursor INTO @DateOfHoliday
         END
     CLOSE idCursor
     DEALLOCATE idCursor

	 EXEC spInsert_SetHoliday;
	 EXEC spInsert_SetHoliday1;

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_HolidayMasterUpdate]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_HolidayMasterUpdate]    
(@HolidayStartDate datetime, @HolidayEndDate datetime, @Reason NVARCHAR(max),@NumberOfDays int,@RecId bigint)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     -- UPDATE previous holiday as PRESENT
     --declare @RecId bigint
     --set @RecId=38
     declare @HolidayStartDate1 date , @HolidayEndDate1 date
     DECLARE @TempTable TABLE (  DateOfHoliday      date)
     set @HolidayStartDate1=(select HolidayStartDate from tblEmpHoliday where RecId=@RecId)
     set @HolidayEndDate1=(select HolidayEndDate from tblEmpHoliday where RecId=@RecId)
     declare @NumOfDays int
     set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate1, @HolidayEndDate1) AS DateDiff)
     set @NumOfDays= @NumOfDays+1
     --print @NumOfDays

     DECLARE @date_value INT;
     SET @date_value = 0;

     WHILE @date_value < @NumOfDays
     BEGIN
         Insert into @TempTable(DateOfHoliday) values(DATEADD(day,@date_value , @HolidayStartDate1))
        SET @date_value = @date_value + 1;
     END;

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday FROM @TempTable
     DECLARE @DateOfHoliday date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
              set @month=(select DATENAME(MM,@DateOfHoliday))
              set @year=(select DATENAME(YYYY,@DateOfHoliday))
              set @Day=(select DATENAME(DD,@DateOfHoliday))

              declare @SqlQuery nvarchar(200)
              set @SqlQuery='update tblMonthData set ['+@Day+']=''P'' where PresentMonth='''+@month+''' and  PresentYear= '+@year +'and ['+@Day+'] !=''WO''' +'and ['+@Day+'] !=''C'''
              --print @SqlQuery
              execute sp_sqlexec @SqlQuery

              FETCH NEXT FROM idCursor INTO @DateOfHoliday
         END
     CLOSE idCursor
     DEALLOCATE idCursor
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     declare @editdate datetime,@EmployeeID nvarchar(20)
     select @editdate = (select GETDATE())

     set @EmployeeID= (SELECT EmployeeID from tblEmpHoliday where RecId=@RecId)
     
     update tblEmpHoliday set HolidayStartDate=@HolidayStartDate,HolidayEndDate=@HolidayEndDate,Reason=@Reason,NumberOfDays=@NumberOfDays,LastEditTime=@editdate where RecId=@RecId 
         
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     -- UPDATE tblMonthData and Insert REASON between chosen date. 
     DECLARE @TempTable1 TABLE (  DateOfHoliday1         date)
     declare @NumOfDays1 int
     set @NumOfDays1 = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
     set @NumOfDays1= @NumOfDays1+1
     --print @NumOfDays1


     DECLARE @date_value1 INT;
     SET @date_value1 = 0;

     WHILE @date_value1 < @NumOfDays1
     BEGIN
         Insert into @TempTable1(DateOfHoliday1) values(DATEADD(day,@date_value1 , @HolidayStartDate))
        SET @date_value1 = @date_value1 + 1;
     END;
     --select * from @TempTable
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday1 FROM @TempTable1
     DECLARE @DateOfHoliday1 date

     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday1
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
              set @month1=(select DATENAME(MM,@DateOfHoliday1))
              set @year1=(select DATENAME(YYYY,@DateOfHoliday1))
              set @Day1=(select DATENAME(DD,@DateOfHoliday1))

              declare @SqlQuery1 nvarchar(200)
              set @SqlQuery1='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1 +' and  EmployeeID='+ @EmployeeID +'and ['+@Day1+'] !=''WO'''+'and ['+@Day1+'] !=''C'''
              --print @SqlQuery1
              execute sp_sqlexec @SqlQuery1

              FETCH NEXT FROM idCursor INTO @DateOfHoliday1
         END
     CLOSE idCursor
     DEALLOCATE idCursor
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ManDays_EmployeeWise]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ManDays_EmployeeWise]    
(@ProjectCode NVARCHAR(max),@SupervisorID NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @TempTable0 table (MonthName1 nvarchar(50))

     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](500),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10)  ,[Remarks][nvarchar](max)
     )

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectName] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](500),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) , [AssignD] float )

     declare @TempTable5 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, [Assign Days] float, [Tasks] nvarchar(max))
     declare @TempTable6 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, [Assign Days] float, [Tasks] nvarchar(max))

              if(@Month != '')
              BEGIN
              -------------------------------------------------------------------------------------------------------
              insert into @TempTable0(MonthName1) values(@Month)
              -------------------------------------------------------------------------------------------------------
              END
              else 
              BEGIN 
              -------------------------------------------------------------------------------------------------------
              insert into @TempTable0
              SELECT DATENAME(MONTH, '2012-' + CAST(number as varchar(2)) + '-1') monthname
              FROM master..spt_values
              WHERE Type = 'P' and number between 1 and 12
              ORDER BY Number
              -------------------------------------------------------------------------------------------------------
              END


              DECLARE idCursor4 CURSOR                     --iterates over IDs present in the data set
              LOCAL FORWARD_ONLY FAST_FORWARD               --optimising for speed and memory
              FOR SELECT MonthName1 FROM @TempTable0
              DECLARE @MonthName1 nvarchar(100)
              OPEN idCursor4 
                  FETCH NEXT FROM idCursor4 INTO @MonthName1
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  set @Month = @MonthName1

                  declare @SqlQuery nvarchar(300)
                  set @SqlQuery = 'select * from tblMonthData where EmployeeID= '+ @SupervisorID
                  if(@Month !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentMonth = '''+@Month +''''
                  end
                  if(@Year !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentYear = '+@Year
                  end
print @SqlQuery
                  insert into @TempTable1
                  EXECUTE sp_executesql @SqlQuery

--select * from @TempTable1

                  declare @COuNt321 as int = 0 
                  set @COuNt321 = (select count(*) from @TempTable1)

                  if(@COuNt321 > 0)
                  begin
                  ------------------------------------------------------------------------------------------------------------
                  insert into @TempTable5 (EmployeeID) values(@MonthName1)

                  DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,Task,
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),@Task nvarchar(500),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID

              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'
              declare @PresentDays int, @counter int , @AssignedDays float
              set @counter=1 
              set @PresentDays=0
              set @AssignedDays=0.0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 1
                            Set @AssignedDays += 0.0
                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += 1
                            Set @AssignedDays += @value321
                       End

                  Set @counter = @counter +1 
              End

              insert into @TempTable2(RecId,EmployeeID,ProjectName,ProjectCode,ManDays,[Task],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[AssignD])  --,[UnassignD]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectName from @TempTable3),(select top(1) ProjectCode from @TempTable3),@PresentDays,@Task,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@AssignedDays) --,@UnassignedDays)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     declare @TempTable4 table (EmployeeID nvarchar(max),ProjectCode nvarchar(max),ProjectName nvarchar(max),Task nvarchar(max))
     

     insert into @TempTable4
     select EmployeeID,ProjectCode,ProjectName,Task from @TempTable2

--select * from @TempTable2
--select * from @TempTable4

     DECLARE idCursor2 CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  EmployeeID,ProjectCode,ProjectName,Task FROM @TempTable4
         DECLARE @EmployeeID12 nvarchar(max),@ProjectCode12 nvarchar(max),@ProjectName12 nvarchar(max),@Task12 nvarchar(max)
         OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @EmployeeID12,@ProjectCode12,@ProjectName12,@Task12
         WHILE @@FETCH_STATUS=0
              BEGIN

              declare @Average float , @MonthDiff int , @Sdate date , @Edate date , @TotalHours int , @AssignedDays1 float , @UnassignDay float
              set @Edate=(select ProjectEndDate from tblProject where ProjectCode=+@ProjectCode12) 
              set @Sdate=(select ProjectStartDate from tblProject where ProjectCode=+@ProjectCode12)
--print @Edate
--print @Sdate         
              set @TotalHours=(select sum(ManDays) from @TempTable2 where EmployeeID=+@EmployeeID12 and [ProjectCode]=+@ProjectCode12 and [Task]=+@Task12)
              set @AssignedDays1=(select sum(AssignD) from @TempTable2 where EmployeeID=+@EmployeeID12  and [ProjectCode]=+@ProjectCode12 and [Task]=+@Task12)

--@TotalHours
--print @AssignedDays1
              
              insert into @TempTable5 (EmployeeID,ProjectName,ProjectCode,ProjectStartDate,ProjectEndDate,[Assign Days],[Tasks])
         values(@EmployeeID12,@ProjectName12,@ProjectCode12,@Sdate,@Edate,round(@AssignedDays1,1),@Task12)

              FETCH NEXT FROM idCursor2 INTO @EmployeeID12,@ProjectCode12,@ProjectName12,@Task12
              END
         CLOSE idCursor2
         DEALLOCATE idCursor2

         declare @assignedD float
              set @assignedD = round((Select Sum([Assign Days]) from @TempTable5),1)
--print @assignedD


              insert into @TempTable5 (ProjectCode,[Assign Days])
              values('ASSIGNED DAYS',round((Select Sum([Assign Days]) from @TempTable5),1))

              insert into @TempTable5 (ProjectCode,[Assign Days])
              values('TOTAL DAYS',round((Select top 1 [ManDays] from @TempTable2),1))

              declare @ADays float , @tot1 float 
              set @tot1 = round((Select top 1 [ManDays] from @TempTable2),1) 
--print @tot1
              set @ADays=  (@tot1 - @assignedD)

              insert into @TempTable5 (ProjectCode,[Assign Days])
              values('AVAILABLE DAYS',round(@ADays,1))

         insert into @TempTable6
         select * from @TempTable5

         delete from @TempTable5
         -------------------------------------------------------------------------------------------------------
         delete from @TempTable1 
         delete from @TempTable2
         delete from @TempTable4


                  ------------------------------------------------------------------------------------------------------------
                  end

              FETCH NEXT FROM idCursor4 INTO @MonthName1
              END
              CLOSE idCursor4
              DEALLOCATE idCursor4


                  
select * from @TempTable6

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ManDays_ProjectWise]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ManDays_ProjectWise]    
(@ProjectCode NVARCHAR(max),@SupervisorID NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @PID bigint
     if(@ProjectCode != '')
     begin
     set @PID = (select ProjectID from tblProject where ProjectCode like '%'+@ProjectCode+'%')
     end

     declare @TempTable0 table (MonthName1 nvarchar(50))

     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) ,[Remarks][nvarchar](max) )   

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectName] [nvarchar](max),[ProjectCode] [nvarchar](max),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) , [AssignD] float )

     
     declare @TempTable5 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, TotalManDays int , [Assign Days (on this project)] float, [Overall Assign Days] float, [Un-Assign Days] float)
     declare @TempTable6 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, TotalManDays int , [Assign Days (on this project)] float, [Overall Assign Days] float, [Un-Assign Days] float)

     if(@Month != '')
     BEGIN
     -------------------------------------------------------------------------------------------------------
     insert into @TempTable0(MonthName1) values(@Month)
     -------------------------------------------------------------------------------------------------------
     END
     else 
     BEGIN 
     -------------------------------------------------------------------------------------------------------
     insert into @TempTable0
     SELECT DATENAME(MONTH, '2012-' + CAST(number as varchar(2)) + '-1') monthname
     FROM master..spt_values
     WHERE Type = 'P' and number between 1 and 12
     ORDER BY Number
     -------------------------------------------------------------------------------------------------------
     END
--select * from @TempTable0
     DECLARE idCursor4 CURSOR                     --iterates over IDs present in the data set
     LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT MonthName1 FROM @TempTable0
     DECLARE @MonthName1 nvarchar(100)
     OPEN idCursor4 
         FETCH NEXT FROM idCursor4 INTO @MonthName1
         WHILE @@FETCH_STATUS=0
         BEGIN
         set @Month = @MonthName1
         -------------------------------------------------------------------------------------------------------
              declare @SqlQuery2 nvarchar(300)
              set @SqlQuery2 = 'select * from tblMonthData where ProjectID='+ cast(@PID as nvarchar(10))
              if(@Month !='')
              begin
              set @SqlQuery2 = @SqlQuery2 + ' and PresentMonth = '''+@Month +''''
              end
              if(@Year !='')
              begin
              set @SqlQuery2 = @SqlQuery2 + ' and PresentYear = '+@Year
              end

              insert into @TempTable1
              EXECUTE sp_executesql @SqlQuery2
--select * from @TempTable1 
              declare @COuNt321 as int = 0 
              set @COuNt321 = (select count(*) from @TempTable1)

              if(@COuNt321 > 0)
              begin

              insert into @TempTable5 (EmployeeID) values(@MonthName1)

              DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
              LOCAL FORWARD_ONLY FAST_FORWARD               --optimising for speed and memory
              FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,
         [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] FROM @TempTable1
              DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),
              @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
              @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
              @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10)
              OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
              WHILE @@FETCH_STATUS=0
                  BEGIN
                       declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
                       insert into @TempTable3
                       select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID

                       DECLARE @EmpNameID nvarchar(100)
                       set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'
                       declare @PresentDays int, @counter int , @AssignedDays float
                       set @counter=1 
                       set @PresentDays=0
                       set @AssignedDays=0.0
                       While (@counter < 32)
                       Begin
                       Declare @value321 nvarchar(20),@query1 nvarchar(300)
                       set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
                       EXECUTE sp_executesql @Query=@query1 , 
                                @Params = N'@value321 NVARCHAR(20) OUTPUT',
                                @value321= @value321 OUTPUT  

                            If (@value321 = 'P') 
                                Begin
                                     Set @PresentDays += 1
                                     Set @AssignedDays += 0.0
                                End
                            else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                                Begin
                                     Set @PresentDays += 1
                                     Set @AssignedDays += @value321
                                End

                            Set @counter = @counter +1 
                       End

                       insert into @TempTable2(RecId,EmployeeID,ProjectName,ProjectCode,ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[AssignD])  --,[UnassignD]) 
                       values(@RecId,@EmpNameID,(select top(1) ProjectName from @TempTable3),(select top(1) ProjectCode from @TempTable3),@PresentDays,
                  @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@AssignedDays) --,@UnassignedDays)

                       delete from @TempTable3;

                       FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
                  END
              CLOSE idCursor
              DEALLOCATE idCursor

              declare @TempTable4 table (EmployeeID nvarchar(max),ProjectCode nvarchar(max),ProjectName nvarchar(max))

              insert into @TempTable4
              select distinct EmployeeID,ProjectCode,ProjectName from @TempTable2

--select * from @TempTable2
--select * from @TempTable4
              ---------  TEMP TABLE 4 LOOP START--------------          
              DECLARE idCursor2 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  EmployeeID,ProjectCode,ProjectName FROM @TempTable4
                  DECLARE @EmployeeID12 nvarchar(max),@ProjectCode12 nvarchar(max),@ProjectName12 nvarchar(max)
                  OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @EmployeeID12,@ProjectCode12,@ProjectName12
                  WHILE @@FETCH_STATUS=0
                       BEGIN
                       declare @Average float , @Sdate date , @Edate date , @TotalHours int , @AvgHoursperMonth float , @CountMonth float, @AssignedDays1 float , @OverallassignDay float, @UnassignDay float
                       set @Edate=(select ProjectEndDate from tblProject where ProjectCode=+@ProjectCode12)
                       set @Sdate=(select ProjectStartDate from tblProject where ProjectCode=+@ProjectCode12)
                       set @TotalHours=(select top 1  ManDays from @TempTable2 where EmployeeID=+@EmployeeID12 )
                       set @AssignedDays1=(select sum(AssignD) from @TempTable2 where EmployeeID=+@EmployeeID12 )
--print @TotalHours
                       declare @EID1 nvarchar(20)
                       set @EID1 = (select SUBSTRING(@EmployeeID12, CHARINDEX('(', @EmployeeID12)+1,6))
                       declare @EmployeeName nvarchar(100),@SupervisorID1 nvarchar(100)
                       set @EmployeeName=(select EmployeeName from tblEmployee where EmployeeID=+@EID1)
                       set @SupervisorID1=(select DirectSupervisor from tblEmployee where EmployeeID=+@EID1)

                       Declare @Output float
                       execute spInsert_SupervisorWise_1 @SupervisorID1,@EmployeeName,@Month,@Year,@Output output
                       set @OverallassignDay=@Output;
                       set @UnassignDay=(@TotalHours-@OverallassignDay)
                       insert into @TempTable5 (EmployeeID,ProjectName,ProjectCode,ProjectStartDate,ProjectEndDate,TotalManDays,[Assign Days (on this project)],[Overall Assign Days] , [Un-Assign Days])
                  values(@EmployeeID12,@ProjectName12,@ProjectCode12,@Sdate,@Edate,@TotalHours,round(@AssignedDays1,1),round(@OverallassignDay,1),round(@UnassignDay,1) )

                       FETCH NEXT FROM idCursor2 INTO @EmployeeID12,@ProjectCode12,@ProjectName12
                       END
                  CLOSE idCursor2
                  DEALLOCATE idCursor2
                  ---------  TEMP TABLE 4 LOOP END--------------        
         insert into @TempTable5 (ProjectCode,TotalManDays,[Assign Days (on this project)],[Overall Assign Days] , [Un-Assign Days])
         values('TOTAL MAN-DAYS',(Select Sum(TotalManDays) from @TempTable5),round((Select Sum([Assign Days (on this project)]) from @TempTable5),1),round((Select Sum([Overall Assign Days]) from @TempTable5),1),round((Select Sum([Un-Assign Days]) from @TempTable5),1))
         
         insert into @TempTable6
         select * from @TempTable5

         delete from @TempTable5
         -------------------------------------------------------------------------------------------------------
         delete from @TempTable1 
         delete from @TempTable2
         delete from @TempTable4

end

              

         FETCH NEXT FROM idCursor4 INTO @MonthName1
         END
     CLOSE idCursor4
     DEALLOCATE idCursor4



     ----------------------------------------------------
     SELECT * FROM @TempTable6
     ----------------------------------------------------

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ManDaysWise]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ManDaysWise]    
(@ProjectCode NVARCHAR(max),@SupervisorID NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @PID bigint
     if(@ProjectCode != '')
     begin
     set @PID = (select ProjectID from tblProject where ProjectCode like '%'+@ProjectCode+'%')
     end
--print 'projectID  : ' +  cast(@PID as nvarchar(20))

     declare @TempTable table ( EmployeeID nvarchar(50) )

     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10)  
     )
--print 'STEP 1'
     if(@SupervisorID != '')
     begin
     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'
--select * from @TempTable
--declare @RecIdMD int
     end
--print 'STEP 2'   
     declare @countTblRow int = 0
     set @countTblRow = (select count(*) from @TempTable)

     if(@countTblRow > 0)
     begin
--print 'STEP 3'   
         DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  EmployeeID FROM @TempTable
         DECLARE @EmployeeID nvarchar(50)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
         WHILE @@FETCH_STATUS=0
              BEGIN
                  declare @SqlQuery nvarchar(300)
                  set @SqlQuery = 'select * from tblMonthData where EmployeeID= '+ @EmployeeID + ' and  ProjectID= '+ cast(@PID as nvarchar(10))
                  if(@Month !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentMonth = '''+@Month +''''
                  end
                  if(@Year !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentYear = '+@Year
                  end
--print @SqlQuery
                  insert into @TempTable1
                  EXECUTE sp_executesql @SqlQuery
                  FETCH NEXT FROM idCursor INTO @EmployeeID
              END
         CLOSE idCursor
         DEALLOCATE idCursor
     end
     else
     begin
                  --print 'STEP 4'   
                  declare @SqlQuery2 nvarchar(300)
                  set @SqlQuery2 = 'select * from tblMonthData where ProjectID='+ cast(@PID as nvarchar(10))
                  if(@Month !='')
                  begin
                  set @SqlQuery2 = @SqlQuery2 + ' and PresentMonth = '''+@Month +''''
                  end
                  if(@Year !='')
                  begin
                  set @SqlQuery2 = @SqlQuery2 + ' and PresentYear = '+@Year
                  end
--print @SqlQuery2
                  insert into @TempTable1
                  EXECUTE sp_executesql @SqlQuery2
     end

--select * from @TempTable1 

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectName] [nvarchar](max),[ProjectCode] [nvarchar](max),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) , [AssignD] float ) --, [UnassignD] float)

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID

              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'
              declare @PresentDays int, @counter int , @AssignedDays float --, @UnassignedDays float
              set @counter=1 
              set @PresentDays=0
              set @AssignedDays=0.0
              --set @UnassignedDays=0.0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 1
                            Set @AssignedDays += 0.0
                            --Set @UnassignedDays += 1.0
                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += 1
                            Set @AssignedDays += @value321
                            --Set @UnassignedDays += (1.0 - @value321)
                       End

                  Set @counter = @counter +1 
              End

--print @AssignedDays
--print @UnassignedDays

              insert into @TempTable2(RecId,EmployeeID,ProjectName,ProjectCode,ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[AssignD])  --,[UnassignD]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectName from @TempTable3),(select top(1) ProjectCode from @TempTable3),@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@AssignedDays) --,@UnassignedDays)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     declare @TempTable4 table (EmployeeID nvarchar(max),ProjectCode nvarchar(max),ProjectName nvarchar(max))
     declare @TempTable5 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, TotalManDays int , [Assign Days (on this project)] float, [Overall Assign Days] float, [Un-Assign Days] float)

     insert into @TempTable4
     select distinct EmployeeID,ProjectCode,ProjectName from @TempTable2

--select * from @TempTable2

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  EmployeeID,ProjectCode,ProjectName FROM @TempTable4
         DECLARE @EmployeeID12 nvarchar(max),@ProjectCode12 nvarchar(max),@ProjectName12 nvarchar(max)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID12,@ProjectCode12,@ProjectName12
         WHILE @@FETCH_STATUS=0
              BEGIN

              declare @Average float , @MonthDiff int , @Sdate date , @Edate date , @TotalHours int , @AvgHoursperMonth float , @CountMonth float, @AssignedDays1 float , @OverallassignDay float, @UnassignDay float
              set @Edate=(select ProjectEndDate from tblProject where ProjectCode=+@ProjectCode12)
              set @Sdate=(select ProjectStartDate from tblProject where ProjectCode=+@ProjectCode12)
              set  @MonthDiff = (SELECT DATEDIFF(month, @Sdate, @Edate))
--print @MonthDiff
              set @TotalHours=(select sum(ManDays) from @TempTable2 where EmployeeID=+@EmployeeID12 )
              set @AssignedDays1=(select sum(AssignD) from @TempTable2 where EmployeeID=+@EmployeeID12 )
--print 'STEP 1'
              declare @EID1 nvarchar(20)
              set @EID1 = (select SUBSTRING(@EmployeeID12, CHARINDEX('(', @EmployeeID12)+1,6))
              declare @EmployeeName nvarchar(100),@SupervisorID1 nvarchar(100)
              --select EmployeeName from tblEmployee where EmployeeID=+@EID1
              set @EmployeeName=(select EmployeeName from tblEmployee where EmployeeID=+@EID1)
--print @EmployeeName
              set @SupervisorID1=(select DirectSupervisor from tblEmployee where EmployeeID=+@EID1)
--print @SupervisorID1

              Declare @Output float
              execute spInsert_SupervisorWise_1 @SupervisorID1,@EmployeeName,@Month,@Year,@Output output
              --print @Output
              set @OverallassignDay=@Output;
              set @UnassignDay=(@TotalHours-@OverallassignDay)

              

              --set @UnassignedDays1=(select sum(UnassignD) from @TempTable2 where EmployeeID=+@EmployeeID12 )
              
              insert into @TempTable5 (EmployeeID,ProjectName,ProjectCode,ProjectStartDate,ProjectEndDate,TotalManDays,[Assign Days (on this project)],[Overall Assign Days] , [Un-Assign Days])
         values(@EmployeeID12,@ProjectName12,@ProjectCode12,@Sdate,@Edate,@TotalHours,round(@AssignedDays1,1),round(@OverallassignDay,1),round(@UnassignDay,1) )  --,round(@UnassignedDays1,1))

              FETCH NEXT FROM idCursor INTO @EmployeeID12,@ProjectCode12,@ProjectName12
              END
         CLOSE idCursor
         DEALLOCATE idCursor


         insert into @TempTable5 (ProjectCode,TotalManDays,[Assign Days (on this project)],[Overall Assign Days] , [Un-Assign Days])  --,[UnAssign Days])
              values('TOTAL MAN-DAYS',(Select Sum(TotalManDays) from @TempTable5),round((Select Sum([Assign Days (on this project)]) from @TempTable5),1),round((Select Sum([Overall Assign Days]) from @TempTable5),1),round((Select Sum([Un-Assign Days]) from @TempTable5),1))

     select * from @TempTable5
     --select * from @TempTable2
     

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ManDaysWise1_SAMPLE]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ManDaysWise1_SAMPLE]    
(@ProjectCode NVARCHAR(max),@SupervisorID NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @PID bigint
     if(@ProjectCode != '')
     begin
     set @PID = (select ProjectID from tblProject where ProjectCode like '%'+@ProjectCode+'%')
     end
--print 'projectID  : ' +  cast(@PID as nvarchar(20))

     declare @TempTable table ( EmployeeID nvarchar(50) )

     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10)  
     )
--print 'STEP 1'
     if(@SupervisorID != '')
     begin
     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'
--select * from @TempTable
     --declare @RecIdMD int
     end
--print 'STEP 2'   
     declare @countTblRow int = 0
     set @countTblRow = (select count(*) from @TempTable)

     if(@countTblRow > 0)
     begin
--print 'STEP 3'   
         DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  EmployeeID FROM @TempTable
         DECLARE @EmployeeID nvarchar(50)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
         WHILE @@FETCH_STATUS=0
              BEGIN
                  declare @SqlQuery nvarchar(300)
                  set @SqlQuery = 'select * from tblMonthData where EmployeeID= '+ @EmployeeID + ' and  ProjectID= '+ cast(@PID as nvarchar(10))
                  if(@Month !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentMonth = '''+@Month +''''
                  end
                  if(@Year !='')
                  begin
                  set @SqlQuery = @SqlQuery + ' and PresentYear = '+@Year
                  end
                  --print @SqlQuery
                  insert into @TempTable1
                  EXECUTE sp_executesql @SqlQuery
                  FETCH NEXT FROM idCursor INTO @EmployeeID
              END
         CLOSE idCursor
         DEALLOCATE idCursor
     end
     else
     begin
                  --print 'STEP 4'   
                  declare @SqlQuery2 nvarchar(300)
                  set @SqlQuery2 = 'select * from tblMonthData where ProjectID='+ cast(@PID as nvarchar(10))
                  if(@Month !='')
                  begin
                  set @SqlQuery2 = @SqlQuery2 + ' and PresentMonth = '''+@Month +''''
                  end
                  if(@Year !='')
                  begin
                  set @SqlQuery2 = @SqlQuery2 + ' and PresentYear = '+@Year
                  end
                  --print @SqlQuery2
                  insert into @TempTable1
                  EXECUTE sp_executesql @SqlQuery2
     end

--select * from @TempTable1 

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectName] [nvarchar](max),[ProjectCode] [nvarchar](max),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) )

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID

              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'
              declare @PresentDays int, @counter int
              set @counter=1 
              set @PresentDays=0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 1
                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += 1
                       End

                  Set @counter = @counter +1 
              End

              insert into @TempTable2(RecId,EmployeeID,ProjectName,ProjectCode,ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectName from @TempTable3),(select top(1) ProjectCode from @TempTable3),@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     declare @TempTable4 table (EmployeeID nvarchar(max),ProjectCode nvarchar(max),ProjectName nvarchar(max))
     declare @TempTable5 table (EmployeeID nvarchar(50),ProjectName nvarchar(max),ProjectCode nvarchar(max),ProjectStartDate date , ProjectEndDate date, TotalManDays int)

     insert into @TempTable4
     select distinct EmployeeID,ProjectCode,ProjectName from @TempTable2

     --select * from @TempTable2

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
         LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
         FOR SELECT  EmployeeID,ProjectCode,ProjectName FROM @TempTable4
         DECLARE @EmployeeID12 nvarchar(max),@ProjectCode12 nvarchar(max),@ProjectName12 nvarchar(max)
         OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID12,@ProjectCode12,@ProjectName12
         WHILE @@FETCH_STATUS=0
              BEGIN

              declare @Average float , @MonthDiff int , @Sdate date , @Edate date , @TotalHours int , @AvgHoursperMonth float , @CountMonth float
              set @Edate=(select ProjectEndDate from tblProject where ProjectCode=+@ProjectCode12)
              set @Sdate=(select ProjectStartDate from tblProject where ProjectCode=+@ProjectCode12)
              set  @MonthDiff = (SELECT DATEDIFF(month, @Sdate, @Edate))
              --print @MonthDiff
              set @TotalHours=(select sum(ManDays) from @TempTable2 where EmployeeID=+@EmployeeID12 )
              --set @CountMonth = (select count(*) from @TempTable2 where EmployeeID=+@EmployeeID12 )
              --if(@Month ='' and @Year ='')
              --begin
              --set @AvgHoursperMonth = (cast(@TotalHours as float) / cast(@CountMonth as float))
              --end
              --if(@Month !='' and @Year ='')
              --begin
              --set @AvgHoursperMonth = (cast(@TotalHours as float) / cast(@CountMonth as float))
              --end
              --if(@Month ='' and @Year !='')
              --begin
              --set @AvgHoursperMonth = (cast(@TotalHours as float) / cast(@CountMonth as float))
              --end
              --if(@Month !='' and @Year !='')
              --begin
              --set @AvgHoursperMonth = (cast(@TotalHours as float)/ cast(@CountMonth as float))
              --end
              --print @TotalHours
              --print @AvgHoursperMonth

              insert into @TempTable5 (EmployeeID,ProjectName,ProjectCode,ProjectStartDate,ProjectEndDate,TotalManDays)
         values(@EmployeeID12,@ProjectName12,@ProjectCode12,@Sdate,@Edate,@TotalHours)

              FETCH NEXT FROM idCursor INTO @EmployeeID12,@ProjectCode12,@ProjectName12
              END
         CLOSE idCursor
         DEALLOCATE idCursor


         insert into @TempTable5 (ProjectCode,TotalManDays)
              values('TOTAL MAN-DAYS',(Select Sum(TotalManDays) from @TempTable5))

     select * from @TempTable5
     --select * from @TempTable2
     

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_MonthData]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_MonthData]    
(@txtEmployeeID NVARCHAR(max),@txtEmployeeName NVARCHAR(max),@txtProjectCode NVARCHAR(max),@ProjectStart datetime, @ProjectEnd datetime)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY

     declare @ProjectID nvarchar(20)
     set @ProjectID=(select ProjectID from tblProject where ProjectCode=@txtProjectCode)
     
     DECLARE @TempTable TABLE
              (    
                [MonthName]      varchar(20),
                [MonthNumber]    VARCHAR(10),
                [LastDayOfMonth] VARCHAR(10),
               [MonthYear] VARCHAR(10)
                )

              declare @start DATE = cast(@ProjectStart as date)
              declare @end DATE = cast(@ProjectEnd as date)

              ;with months (date)
              AS
              (
                  SELECT @start
                  UNION ALL
                  SELECT DATEADD(month, 1, date)
                  from months
                  where DATEADD(month, 1, date) <= @end
              )
              insert into @TempTable
              select     [MonthName]    = DATENAME(mm, date),
                          [MonthNumber]  = DATEPART(mm, date),  
                          [LastDayOfMonth]  = DATEPART(dd, EOMONTH(date)),
                          [MonthYear]    = DATEPART(yy, date)
              from months

              select * from @TempTable;

              declare @EmployeeID nvarchar(20)
              --set @EmployeeID = (select EmployeeID from tblEmployee where EmployeeName like '%'+ @txtEmployeeName +'%');
			  set @EmployeeID = @txtEmployeeID

              declare @count1 as int
              set @count1=(select count([MonthName]) from @TempTable)
              print @count1

              DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  [MonthName], [MonthNumber],[LastDayOfMonth],[MonthYear]
        FROM @TempTable

     --SELECT  [LoggingTime], [Signal01] FROM @TempTable1

     DECLARE @MonthName varchar(20), @MonthNumber varchar(20) , @LastDayOfMonth varchar(20) ,@MonthYear varchar(20) 

     OPEN idCursor FETCH NEXT FROM idCursor INTO @MonthName, @MonthNumber, @LastDayOfMonth, @MonthYear
     WHILE @@FETCH_STATUS=0
         BEGIN
              insert into tblMonthData(EmployeeID,ProjectID,PresentMonth,PresentYear,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],
         [18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
         values(@EmployeeID,@ProjectID,@MonthName,@MonthYear,'P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P')

              FETCH NEXT FROM idCursor INTO @MonthName, @MonthNumber, @LastDayOfMonth, @MonthYear
         END
     CLOSE idCursor
     DEALLOCATE idCursor

	 execute spInsert_SetHoliday

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ProjectMaster]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ProjectMaster]    
(
@Const int,
@ProjectID bigint,
@ProjectCode NVARCHAR(max),
@ProjectType NVARCHAR(max),
@ProjectName NVARCHAR(max),
@ProjectStartDate Date, 
@ProjectEndDate Date, 
@OldProjectEndDate date,
@ProjectCategory NVARCHAR(max),
@ProjectSegment	 NVARCHAR(max),
@ProjectStage	 NVARCHAR(max),
@ProjectStatus	 NVARCHAR(max),
@Reporting		 NVARCHAR(max),
@ProjectManager NVARCHAR(max),
@OperatorName NVARCHAR(max)
)

AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY

EXEC spInsert_SetHoliday;
     
     declare @editdate datetime
     select @editdate = (select GETDATE())

     if (@Const=1)
     begin
     INSERT INTO tblProject 
		(		
		ProjectID,
		ProjectCode,
		ProjectType,
		ProjectName,
		ProjectStartDate,
		ProjectEndDate,
		ProjectCategory,
        ProjectSegment,
        ProjectStage,
        ProjectStatus,
        Reporting,
		ProjectManager,
		OperatorName,
		LastEditTime
		)
     VALUES
		(
		@ProjectID,
		@ProjectCode,
		@ProjectType,
		@ProjectName,
		@ProjectStartDate,
		@ProjectEndDate,
		@ProjectCategory, 
        @ProjectSegment, 
        @ProjectStage, 
        @ProjectStatus,
        @Reporting,
		@ProjectManager,
		@OperatorName,
		@editdate)
     end

     if (@Const=2)
     begin    
     UPDATE tblProject 
     SET 
	 ProjectType		= @ProjectType,
	 ProjectName		= @ProjectName,
	 ProjectStartDate	= @ProjectStartDate,
     ProjectEndDate		= @ProjectEndDate ,
	 ProjectCategory	= @ProjectCategory  ,
     ProjectSegment		= ProjectSegment ,
     ProjectStage		= @ProjectStage ,
     ProjectStatus		= @ProjectStatus ,
     Reporting			= @Reporting ,
	 ProjectManager		= @ProjectManager,
	 OperatorName		= @OperatorName,
	 LastEditTime		= @editdate, 
	 OldProjectEndDate	= @OldProjectEndDate 
	 WHERE 
	 ProjectCode = @ProjectCode
     end
     

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_ProjectTasks]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_ProjectTasks]
(@EmpId NVARCHAR(max),@ProjectID NVARCHAR(max),@Year NVARCHAR(max),@Month NVARCHAR(max),@Task nvarchar(max))    
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY

     --EXEC spInsert_SetHoliday;

     Insert into tblTask(EmpID,ProjectID,ProjectCode,PMonth,PYear,Task) values (@EmpId,(select ProjectID from tblProject where ProjectCode like '%'+@ProjectID+'%'),@ProjectID,@Month,@Year,@Task)
print 'Hello'
	 declare @ProID nvarchar(15),@SqF nvarchar(15)
	 set @ProID=(select ProjectID from tblProject where ProjectCode like '%'+@ProjectID+'%')
print @ProID
	 set @SqF= (select RecId from tblMonthData where EmployeeID like '%'+@EmpId+'%' and PresentMonth like '%'+@Month+'%'  and PresentYear like '%'+@Year+'%' and ProjectID =@ProID and Task is null)
print @SqF +'_Hello'

    if (@SqF != '')
    begin
--print 'STEP 1'
    --update tblMonthData set Task=@Task where EmployeeID like '%'+@EmpId+'%' and PresentMonth like '%'+@Month+'%'  and PresentYear like '%'+@Year+'%' and ProjectID like '%'+@ProID+'%' and Task is null
    update tblMonthData set Task=@Task where RecId=+@SqF
	end
    else --if(@SqF = '')
    begin
--print 'STEP 2'
    insert into tblMonthData([EmployeeID],[ProjectID],[PresentMonth],[PresentYear],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Task]) 
    values(@EmpId,@ProID,@Month,@Year,'P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P','P',@Task)
    
	--EXEC spInsert_SetHoliday;
	end

	

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SetHoliday]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SetHoliday]    
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @TempTable TABLE (  DateOfHoliday      date  ,DayOfWeek1 nvarchar(100))

     Insert into @TempTable
	 --- *********************************************
	 --- CHANGES FOR THE OPTIMIZATION OF QUERY
	 --- *********************************************
     select DateOfHoliday,DayOfWeek1 from tblHolidayCalander WHERE DATENAME(YYYY,DateOfHoliday)>=DATENAME(YYYY,GETDATE())

     --select * from @TempTable

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  DateOfHoliday,DayOfWeek1 FROM @TempTable
     DECLARE @DateOfHoliday date , @DayOfWeek1 nvarchar(100)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @DateOfHoliday,@DayOfWeek1
     WHILE @@FETCH_STATUS=0
         BEGIN
                  declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
                  set @month=(select DATENAME(MM,@DateOfHoliday))
                  set @year=(select DATENAME(YYYY,@DateOfHoliday))
                  set @Day=(select DATENAME(DD,@DateOfHoliday))
                  
                  -------------------------------------------------------------------------------------------------- 
                  DECLARE @TempTable4 TABLE ( RecID bigint  ,DataValue nvarchar(100))

                  DECLARE  @SqlQuery4 NVARCHAR(300)
                  SET @SqlQuery4='Select RecId, ['+@Day+'] from tblMonthData where PresentMonth='''+@month+''' and  PresentYear= '+@year
                  
                  insert into @TempTable4
                  execute sp_sqlexec @SqlQuery4

                  --select * from @TempTable1;
                  --------------------------------------------------------------------------------------------------
                  DECLARE idCursor4 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  RecID,DataValue FROM @TempTable4
                  DECLARE @RecID bigint , @DataValue nvarchar(100)
                  OPEN idCursor4 FETCH NEXT FROM idCursor4 INTO @RecID,@DataValue
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  --print 'RecID : '+  cast(@RecID as nvarchar(20)) + ' && DataValue : ' + @DataValue
                  declare @SqlQuery5 nvarchar(200)

                  if(LTRIM(RTRIM(@DataValue)) != '0' and LTRIM(RTRIM(@DataValue)) != 'P' and LTRIM(RTRIM(@DataValue)) != 'A' and LTRIM(RTRIM(@DataValue)) != 'PH' and LTRIM(RTRIM(@DataValue)) != 'C' and LTRIM(RTRIM(@DataValue)) != 'WO' and LTRIM(RTRIM(@DataValue)) != 'NA')        
                  begin 
                       if((cast(LTRIM(RTRIM(@DataValue)) as float) between 0.1 and 1) )
                       begin 
                       print 'No Need To Change'
                       end
                  end
                  else if(@DayOfWeek1 = 'C' or @DayOfWeek1 = 'PH' )
                  begin
                       set @SqlQuery5='update tblMonthData set ['+@Day+']='''+@DayOfWeek1+''' where PresentMonth='''+@month+''' and  PresentYear= '+@year+' and RecId = '+ cast(@RecID as nvarchar(20))
                       --print 'Change For C and PH'
                       --print @SqlQuery
                       execute sp_sqlexec @SqlQuery5
                  end
                  else 
                  begin
                       set @SqlQuery5='update tblMonthData set ['+@Day+']=''WO'' where PresentMonth='''+@month+''' and  PresentYear= '+@year+' and RecId = '+ cast(@RecID as nvarchar(20)) 
                       --print 'Change For WO'
                            --print @SqlQuery
                       execute sp_sqlexec @SqlQuery5
                  end

                  FETCH NEXT FROM idCursor4 INTO @RecID,@DataValue
                  END
                  CLOSE idCursor4
                  DEALLOCATE idCursor4
                  ------------------------------------------------------------------------------------------------
                  delete from @TempTable4

         FETCH NEXT FROM idCursor INTO @DateOfHoliday,@DayOfWeek1
         END
     CLOSE idCursor
     DEALLOCATE idCursor
     
	 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @TempTable1 TABLE (EmployeeID nvarchar(100), HolidayStartDate date,HolidayEndDate date)

     Insert into @TempTable1
     --select EmployeeID,HolidayStartDate,HolidayEndDate from tblEmpHoliday where EmployeeID !='000000'
	  --- *********************************************
	 --- CHANGES FOR THE OPTIMIZATION OF QUERY
	 --- *********************************************
	 select EmployeeID,HolidayStartDate,HolidayEndDate from tblEmpHoliday where EmployeeID !='000000' AND DATENAME(YYYY,HolidayEndDate)>=DATENAME(YYYY,GETDATE())
     --select * from @TempTable1

     DECLARE idCursor1 CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID,HolidayStartDate,HolidayEndDate FROM @TempTable1
     DECLARE @EmployeeID nvarchar(100) ,@HolidayStartDate     date ,@HolidayEndDate date 
     OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
     WHILE @@FETCH_STATUS=0
         BEGIN

				declare @NumOfDays int
				 set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
				 set @NumOfDays= @NumOfDays+1
				 --print @NumOfDays	

                  declare @count1    int
                  set @count1=0
                  while(@count1 < @NumOfDays)
                  begin
                            declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
                            set @month1=(select DATENAME(MM,@HolidayStartDate))
                            set @year1=(select DATENAME(YYYY,@HolidayStartDate))
                            set @Day1=(select DATENAME(DD,@HolidayStartDate))

                  DECLARE @TempTable5 TABLE ( RecID bigint  ,DataValue nvarchar(100))

                  DECLARE  @SqlQuery6 NVARCHAR(300)
                  SET @SqlQuery6='select RecId, ['+@Day1+'] from tblMonthData  where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and EmployeeID ='+@EmployeeID
                  --print @SqlQuery6
                  insert into @TempTable5
                  execute sp_sqlexec @SqlQuery6
                  --------------------------------------------------------------------------------------------------
                  DECLARE idCursor5 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  RecID,DataValue FROM @TempTable5
                  DECLARE @RecID1 bigint , @DataValue1 nvarchar(100)
                  OPEN idCursor5 FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  --print 'RecID : '+  cast(@RecID1 as nvarchar(20)) + ' && DataValue : ' + @DataValue1
                  
                  if(LTRIM(RTRIM(@DataValue1)) != 'A' and LTRIM(RTRIM(@DataValue1)) != 'P' and LTRIM(RTRIM(@DataValue1)) != '0')        
                  begin 
                       if((cast(LTRIM(RTRIM(@DataValue1)) as float) between 0.1 and 1) )
                       begin 
                       print 'No Need To Change 1'
                       end
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'A')
                  begin
                       declare @SqlQuery1 nvarchar(200)
                       --print 'Step 1'
                       set @SqlQuery1='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       --print @SqlQuery1
                       execute sp_sqlexec @SqlQuery1
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'P' or LTRIM(RTRIM(@DataValue1)) = '0')
                  begin
                       declare @SqlQuery7 nvarchar(200)
                       --print 'Step 2'
                       set @SqlQuery7='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       --print @SqlQuery7
                       execute sp_sqlexec @SqlQuery7
                  end

                  FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  END
                  CLOSE idCursor5
                  DEALLOCATE idCursor5
                  ------------------------------------------------------------------------------------------------
                  set @HolidayStartDate=(select DATEADD(day,1, @HolidayStartDate))
                  set @count1=@count1+1
                  delete from @TempTable5
                  end
                  
              FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
         END
     CLOSE idCursor1
     DEALLOCATE idCursor1   
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
              DECLARE @TempTable2 TABLE
              (    
                  [MonthName]        varchar(20),
                  [LastDayOfMonth] VARCHAR(10),
                  [MonthYear] VARCHAR(10)
                  )

              declare @start DATE = (Select min(ProjectStartDate) from tblProject)
              declare @end DATE = (Select max(ProjectEndDate) from tblProject)

              ;with months (date)
              AS
              (
                  SELECT @start
                  UNION ALL
                  SELECT DATEADD(month, 1, date)
                  from months
                  where DATEADD(month, 1, date) <= @end
              )
              insert into @TempTable2
              select     [MonthName]    = DATENAME(mm, date),
                          [LastDayOfMonth]  = DATEPART(dd, EOMONTH(date)),
                          [MonthYear]    = DATEPART(yy, date)
              from months

              --select * from @TempTable2;

              DECLARE idCursor2 CURSOR                     --iterates over IDs present in the data set
              LOCAL FORWARD_ONLY FAST_FORWARD               --optimising for speed and memory
              FOR SELECT  [MonthName],[LastDayOfMonth],[MonthYear] FROM @TempTable2
              DECLARE @MonthName nvarchar(100) ,@LastDayOfMonth nvarchar(100),@MonthYear nvarchar(100)
              OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @MonthName,@LastDayOfMonth,@MonthYear
              WHILE @@FETCH_STATUS=0
                  BEGIN
                            declare @count int
                            set @count=@LastDayOfMonth+1
                            while(@count <= 31)
                            begin
                                     --print @count
                                     declare @SqlQuery2 nvarchar(200)
                                     set @SqlQuery2='update tblMonthData set ['+cast(@count as nvarchar(10))+']=''NA'' where PresentMonth='''+@MonthName+''' and  PresentYear= '+@MonthYear
                                     --print @SqlQuery2
                                     execute sp_sqlexec @SqlQuery2
                                     set @count=@count+1
                            end
                  
                       FETCH NEXT FROM idCursor2 INTO @MonthName,@LastDayOfMonth,@MonthYear
                  END
              CLOSE idCursor2
              DEALLOCATE idCursor2
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SetHoliday1]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SetHoliday1]    
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY
     
     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @TempTable1 TABLE (EmployeeID nvarchar(100), HolidayStartDate date,HolidayEndDate date)

     Insert into @TempTable1
     select EmployeeID,HolidayStartDate,HolidayEndDate from tblEmpHoliday where EmployeeID !='000000'
     --select * from @TempTable1

     DECLARE idCursor1 CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID,HolidayStartDate,HolidayEndDate FROM @TempTable1
     DECLARE @EmployeeID nvarchar(100) ,@HolidayStartDate     date ,@HolidayEndDate date 
     OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
     WHILE @@FETCH_STATUS=0
         BEGIN

				declare @NumOfDays int
				 set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
				 set @NumOfDays= @NumOfDays+1
				 print @NumOfDays	

                  declare @count1    int
                  set @count1=0
                  while(@count1 < @NumOfDays)
                  begin
                            declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
                            set @month1=(select DATENAME(MM,@HolidayStartDate))
                            set @year1=(select DATENAME(YYYY,@HolidayStartDate))
                            set @Day1=(select DATENAME(DD,@HolidayStartDate))

                  DECLARE @TempTable5 TABLE ( RecID bigint  ,DataValue nvarchar(100))

                  DECLARE  @SqlQuery6 NVARCHAR(300)
                  SET @SqlQuery6='select RecId, ['+@Day1+'] from tblMonthData  where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and EmployeeID ='+@EmployeeID
                  print @SqlQuery6
                  insert into @TempTable5
                  execute sp_sqlexec @SqlQuery6
                  --------------------------------------------------------------------------------------------------
                  DECLARE idCursor5 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  RecID,DataValue FROM @TempTable5
                  DECLARE @RecID1 bigint , @DataValue1 nvarchar(100)
                  OPEN idCursor5 FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  --print 'RecID : '+  cast(@RecID1 as nvarchar(20)) + ' && DataValue : ' + @DataValue1
                  
                  if(LTRIM(RTRIM(@DataValue1)) != 'A' and LTRIM(RTRIM(@DataValue1)) != 'P' and LTRIM(RTRIM(@DataValue1)) != '0')        
                  begin 
                       if((cast(LTRIM(RTRIM(@DataValue1)) as float) between 0.1 and 1) )
                       begin 
                       print 'No Need To Change 1'
                       end
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'A')
                  begin
                       declare @SqlQuery1 nvarchar(200)
                       --print 'Step 1'
                       set @SqlQuery1='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       print @SqlQuery1
                       execute sp_sqlexec @SqlQuery1
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'P' or LTRIM(RTRIM(@DataValue1)) = '0')
                  begin
                       declare @SqlQuery7 nvarchar(200)
                       --print 'Step 2'
                       set @SqlQuery7='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       print @SqlQuery7
                       execute sp_sqlexec @SqlQuery7
                  end

                  FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  END
                  CLOSE idCursor5
                  DEALLOCATE idCursor5
                  ------------------------------------------------------------------------------------------------
                  set @HolidayStartDate=(select DATEADD(day,1, @HolidayStartDate))
                  set @count1=@count1+1
                  delete from @TempTable5
                  end
                  
              FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
         END
     CLOSE idCursor1
     DEALLOCATE idCursor1   
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SupervisorWise]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SupervisorWise]    
(@SupervisorID NVARCHAR(max),@EmployeeName NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @TempTable table ( EmployeeID nvarchar(50) )
     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10), [Remarks]  [nvarchar](max) 
     )

     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'  and EmployeeName like '%'+@EmployeeName+'%'
--select * from @TempTable
     declare @RecIdMD int
     
     
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID FROM @TempTable
     DECLARE @EmployeeID nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @SqlQuery nvarchar(500)
              set @SqlQuery='select RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],[ManDays],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] from tblMonthData where EmployeeID='+ @EmployeeID +' and PresentYear like ''%'+@Year+'%''' +' and PresentMonth ='''+@Month +''' order by ProjectID'
              insert into @TempTable1
              execute sp_sqlexec @SqlQuery
              
              FETCH NEXT FROM idCursor INTO @EmployeeID
         END
     CLOSE idCursor
     DEALLOCATE idCursor
--select * from @TempTable1

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) ,[Remarks]  [nvarchar](max) )

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),@Task nvarchar(150),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10),@Remarks nvarchar(max)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID
--select * from @TempTable3
              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'

              declare @PresentDays float, @counter int
              set @counter=1 
              set @PresentDays=0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 0.0

                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += @value321
                       End
                  Set @counter = @counter +1 
              End      
              insert into @TempTable2(RecId,EmployeeID,ProjectCode,[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectCode from @TempTable3),@Task,@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
         END
     CLOSE idCursor
     DEALLOCATE idCursor

--select * from @TempTable2

     declare @TempTable4 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](3)  ,[2] [nchar](3)  ,[3] [nchar](3)  ,[4] [nchar](3)  ,[5] [nchar](3)  ,[6] [nchar](3)  ,[7] [nchar](3) ,
     [8] [nchar](3)  ,[9] [nchar](3)  ,[10] [nchar](3) ,[11] [nchar](3) ,[12] [nchar](3) ,[13] [nchar](3) ,[14] [nchar](3) ,
     [15] [nchar](3) ,[16] [nchar](3) ,[17] [nchar](3) ,[18] [nchar](3) ,[19] [nchar](3) ,[20] [nchar](3) ,[21] [nchar](3) ,
     [22] [nchar](3) ,[23] [nchar](3) ,[24] [nchar](3) ,[25] [nchar](3) ,[26] [nchar](3) ,[27] [nchar](3) ,[28] [nchar](3) ,
     [29] [nchar](3) ,[30] [nchar](3) ,[31] [nchar](3),[Remarks]  [nvarchar](max) )
     
     declare @TempTable7 table ( Sum123 [nchar](10) )
     declare @TempTable8 table ( SumBestEff float)
     declare @BestPossibleEffeciency float
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT distinct EmployeeID FROM @TempTable1
     DECLARE @EmployeeID2 nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID2
     WHILE @@FETCH_STATUS=0
         BEGIN
              insert into @TempTable4
              select * from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'
              declare @T1 nchar(10),@T2 nchar(10),@T3 nchar(10),@T4 nchar(10),@T5 nchar(10),@T6 nchar(10),@T7 nchar(10),@T8 nchar(10),@T9 nchar(10),@T10 nchar(10),@T11 nchar(10),@T12 nchar(10),
                       @T13 nchar(10),@T14 nchar(10),@T15 nchar(10),@T16 nchar(10),@T17 nchar(10),@T18 nchar(10),@T19 nchar(10),@T20 nchar(10),@T21 nchar(10),@T22 nchar(10),@T23 nchar(10),
                       @T24 nchar(10),@T25 nchar(10),@T26 nchar(10),@T27 nchar(10),@T28 nchar(10),@T29 nchar(10),@T30 nchar(10),@T31 nchar(10)
              -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                  declare @TempTable6 table ( Values321 [nchar](10) )
                  DECLARE @cnt INT = 1;
                  WHILE @cnt < 32
                  BEGIN
                  delete from @TempTable6
                  declare @SqlQuery2 nvarchar(200)
                       set @SqlQuery2='select ['+cast(@cnt as nvarchar(20))+'] from tblMonthData where EmployeeID ='+ cast(@EmployeeID2 as varchar(50)) +' and PresentMonth ='''+ cast(@Month as nvarchar(20)) +'''and PresentYear = '+ cast(@Year as nvarchar(20))
                       insert into @TempTable6
                       execute sp_sqlexec @SqlQuery2
                       Declare @variable float
                       set @variable=0.0 
                       Declare @variableBestEff float
                       set @variableBestEff=0.0 
                       --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable6               
                       DECLARE idCursor1 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Values321 FROM @TempTable6
                       DECLARE @Values123 [nchar](10)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @Values123
                       WHILE @@FETCH_STATUS=0
                            BEGIN
         
                                     declare @C1 float = (select count(*) from @TempTable6)     
                                          
                                     if(@Values123 = 'A')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += (1.0/@C1)
                                          --break;
                                     end
                                     if(@Values123 = 'WO' or @Values123 = 'PH' or @Values123 = 'C')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += 0.0
                                     end
                                     else if( @Values123 != 'P' and @Values123 != 'WO' and @Values123 != 'PH' and @Values123 != 'C' and @Values123 != 'A' and @Values123 != 'NA')
                                     begin
                                          set @variable += (select cast(@Values123 as float))
                                          set @variableBestEff += 1   --(select cast(@Values123 as float))
                                     end
                                     else if( @Values123 = 'P')
                                     begin 
                                          set @variable +=0.0
                                          set @variableBestEff += (1.0/@C1)
                                     end
                                     else if( @Values123 = 'NA')
                                     begin 
                                          set @variable =0.03
                                          set @variableBestEff += 0
                                     end

                                FETCH NEXT FROM idCursor1 INTO @Values123
                            END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                       ---------------------------------------------------------------------------------------------------------------------------------               
                       insert into @TempTable7(Sum123) values(@variable)
                       if(@variableBestEff > 1)
                       begin
                       set @variableBestEff = 1
                       end
                       insert into @TempTable8(SumBestEff) values(@variableBestEff)
                       set @variable=0.0
                       set @variableBestEff=0.0
                       SET @cnt = @cnt + 1;
                  END;
              ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable7
              
              declare @count123 int
              set @count123=1
              ---------------------------------------------------------------------------------------------------------------------------------------
                       DECLARE idCursor2 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Sum123 FROM @TempTable7
                       DECLARE @Values1234 [nchar](10)
                       OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @Values1234
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                  if(@count123 = 1)begin  set @T1= @Values1234   end if(@count123 = 2)begin set @T2= @Values1234  end
                                  if(@count123 = 3)begin  set @T3= @Values1234   end if(@count123 = 4)begin set @T4= @Values1234  end
                                  if(@count123 = 5)begin  set @T5= @Values1234   end if(@count123 = 6)begin set @T6= @Values1234  end
                                  if(@count123 = 7)begin  set @T7= @Values1234   end if(@count123 = 8)begin set @T8= @Values1234  end
                                  if(@count123 = 9)begin  set @T9= @Values1234   end if(@count123 = 10)begin set @T10= @Values1234  end
                                  if(@count123 = 11)begin set @T11= @Values1234  end if(@count123 = 12)begin set @T12= @Values1234  end
                                  if(@count123 = 13)begin set @T13= @Values1234  end if(@count123 = 14)begin set @T14= @Values1234  end
                                  if(@count123 = 15)begin set @T15= @Values1234  end if(@count123 = 16)begin set @T16= @Values1234  end
                                  if(@count123 = 17)begin set @T17= @Values1234  end if(@count123 = 18)begin set @T18= @Values1234  end
                                  if(@count123 = 19)begin set @T19= @Values1234  end if(@count123 = 20)begin set @T20= @Values1234  end
                                  if(@count123 = 21)begin set @T21= @Values1234  end if(@count123 = 22)begin set @T22= @Values1234  end
                                  if(@count123 = 23)begin set @T23= @Values1234  end if(@count123 = 24)begin set @T24= @Values1234  end
                                  if(@count123 = 25)begin set @T25= @Values1234  end if(@count123 = 26)begin set @T26= @Values1234  end
                                  if(@count123 = 27)begin set @T27= @Values1234  end if(@count123 = 28)begin set @T28= @Values1234  end
                                  if(@count123 = 29)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T29= 'NA' end
                                     else begin set @T29= @Values1234  end
                                  end
                                  if(@count123 = 30)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T30= 'NA' end
                                     else begin set @T30= @Values1234  end
                                  end
                                  if(@count123 = 31)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T31= 'NA' end
                                     else begin set @T31= @Values1234 end
                                  end

                                set @count123 =@count123+1
                                FETCH NEXT FROM idCursor2 INTO @Values1234
                            END
                       CLOSE idCursor2
                       DEALLOCATE idCursor2
              -----------------------------------------------------------------------------------------------------------------------------------------
              Declare @Effeciency float , @total float
              if (@T31 != 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )+cast(@T31 as float )
              end
              if (@T31 = 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 = 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )
              end
              declare @datestring nvarchar(20),@MonthNumDays float
              set @datestring= @Year+'-'+@Month+'-01'
              set @MonthNumDays=(select DAY(EOMONTH(@datestring)))
              set @Effeciency= (@total / @MonthNumDays) * 100
              set @BestPossibleEffeciency = ((select sum(SumBestEff) from @TempTable8)/@MonthNumDays) * 100

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Effeciency(%)',CONVERT(DECIMAL(10,2),@Effeciency),'Assign',CONVERT(DECIMAL(10,2),(select sum(ManDays) from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%')),@T1,@T2,@T3,@T4,@T5,@T6,@T7,@T8,@T9,@T10,@T11,@T12,@T13,@T14,@T15,@T16,@T17,@T18,@T19,@T20,@T21,@T22,@T23,@T24,@T25,@T26,@T27,@T28,@T29,@T30,@T31)
--select * from @TempTable4
              declare @T29_1 nchar(10),@T30_1 nchar(10),@T31_1 nchar(10)           
              if(@T29 = 'NA') begin set @T29_1='NA' end
              else begin set @T29_1 = (1-cast(@T29 as float)) end
              if(@T30 = 'NA') begin set @T30_1='NA' end
              else begin set @T30_1 = (1-cast(@T30 as float)) end
              if(@T31 = 'NA') begin set @T31_1='NA' end
              else begin set @T31_1 = (1-cast(@T31 as float)) end

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Best Effeciency(%)',CONVERT(DECIMAL(10,2),@BestPossibleEffeciency),'Un-Assign',(1-cast(@T1 as float)),(1-cast(@T2 as float)),(1-cast(@T3 as float)),(1-cast(@T4 as float)),(1-cast(@T5 as float)),(1-cast(@T6 as float)),(1-cast(@T7 as float)),(1-cast(@T8 as float)),(1-cast(@T9 as float)),
              (1-cast(@T10 as float)),(1-cast(@T11 as float)),(1-cast(@T12 as float)),(1-cast(@T13 as float)),(1-cast(@T14 as float)),(1-cast(@T15 as float)),(1-cast(@T16 as float)),(1-cast(@T17 as float)),(1-cast(@T18 as float)),(1-cast(@T19 as float)),(1-cast(@T20 as float)),(1-cast(@T21 as float)),(1-cast(@T22 as float)),
              (1-cast(@T23 as float)),(1-cast(@T24 as float)),(1-cast(@T25 as float)),(1-cast(@T26 as float)),(1-cast(@T27 as float)),(1-cast(@T28 as float)),@T29_1,@T30_1,@T31_1)

              set @BestPossibleEffeciency=0.0
              delete from @TempTable7
              delete from @TempTable8
              FETCH NEXT FROM idCursor INTO @EmployeeID2
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     select * from @TempTable4
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SupervisorWise_1]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SupervisorWise_1]    
(@SupervisorID NVARCHAR(max),@EmployeeName NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max),@Output float output)
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
--print @SupervisorID
--print @EmployeeName
--print @Month
--print @Year

     EXEC spInsert_SetHoliday;

     declare @TempTable table ( EmployeeID nvarchar(50) )
     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10)  
     )

     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'  and EmployeeName like '%'+@EmployeeName+'%'
--select * from @TempTable
     declare @RecIdMD int
     
     
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID FROM @TempTable
     DECLARE @EmployeeID nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @SqlQuery nvarchar(500)
              set @SqlQuery='select RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],[ManDays],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] from tblMonthData where EmployeeID='+ @EmployeeID +' and PresentYear like ''%'+@Year+'%''' +' and PresentMonth ='''+@Month +''' order by ProjectID'
              insert into @TempTable1
              execute sp_sqlexec @SqlQuery
              
              FETCH NEXT FROM idCursor INTO @EmployeeID
         END
     CLOSE idCursor
     DEALLOCATE idCursor
--select * from @TempTable1

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) )

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),@Task nvarchar(150),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID
--select * from @TempTable3
              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'

              declare @PresentDays float, @counter int
              set @counter=1 
              set @PresentDays=0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 0.0

                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += @value321
                       End
                  Set @counter = @counter +1 
              End      
              insert into @TempTable2(RecId,EmployeeID,ProjectCode,[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectCode from @TempTable3),@Task,@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31
         END
     CLOSE idCursor
     DEALLOCATE idCursor

--select * from @TempTable2

     declare @TempTable4 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10))
     
     declare @TempTable7 table ( Sum123 [nchar](10) )
     declare @TempTable8 table ( SumBestEff float)
     declare @BestPossibleEffeciency float
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT distinct EmployeeID FROM @TempTable1
     DECLARE @EmployeeID2 nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID2
     WHILE @@FETCH_STATUS=0
         BEGIN
              insert into @TempTable4
              select * from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'
              declare @T1 nchar(10),@T2 nchar(10),@T3 nchar(10),@T4 nchar(10),@T5 nchar(10),@T6 nchar(10),@T7 nchar(10),@T8 nchar(10),@T9 nchar(10),@T10 nchar(10),@T11 nchar(10),@T12 nchar(10),
                       @T13 nchar(10),@T14 nchar(10),@T15 nchar(10),@T16 nchar(10),@T17 nchar(10),@T18 nchar(10),@T19 nchar(10),@T20 nchar(10),@T21 nchar(10),@T22 nchar(10),@T23 nchar(10),
                       @T24 nchar(10),@T25 nchar(10),@T26 nchar(10),@T27 nchar(10),@T28 nchar(10),@T29 nchar(10),@T30 nchar(10),@T31 nchar(10)
              -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                  declare @TempTable6 table ( Values321 [nchar](10) )
                  DECLARE @cnt INT = 1;
                  WHILE @cnt < 32
                  BEGIN
                  delete from @TempTable6
                  declare @SqlQuery2 nvarchar(200)
                       set @SqlQuery2='select ['+cast(@cnt as nvarchar(20))+'] from tblMonthData where EmployeeID ='+ cast(@EmployeeID2 as varchar(50)) +' and PresentMonth ='''+ cast(@Month as nvarchar(20)) +'''and PresentYear = '+ cast(@Year as nvarchar(20))
                       insert into @TempTable6
                       execute sp_sqlexec @SqlQuery2
                       Declare @variable float
                       set @variable=0.0 
                       Declare @variableBestEff float
                       set @variableBestEff=0.0 
                       --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable6               
                       DECLARE idCursor1 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Values321 FROM @TempTable6
                       DECLARE @Values123 [nchar](10)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @Values123
                       WHILE @@FETCH_STATUS=0
                            BEGIN
         
                                     declare @C1 float = (select count(*) from @TempTable6)     
                                          
                                     if(@Values123 = 'A')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += (1.0/@C1)
                                          --break;
                                     end
                                     if(@Values123 = 'WO' or @Values123 = 'PH' or @Values123 = 'C')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += 0.0
                                     end
                                     else if( @Values123 != 'P' and @Values123 != 'WO' and @Values123 != 'PH' and @Values123 != 'C' and @Values123 != 'A' and @Values123 != 'NA')
                                     begin
                                          set @variable += (select cast(@Values123 as float))
                                          set @variableBestEff += 1   --(select cast(@Values123 as float))
                                     end
                                     else if( @Values123 = 'P')
                                     begin 
                                          set @variable +=0.0
                                          set @variableBestEff += (1.0/@C1)
                                     end
                                     else if( @Values123 = 'NA')
                                     begin 
                                          set @variable =0.03
                                          set @variableBestEff += 0
                                     end

                                FETCH NEXT FROM idCursor1 INTO @Values123
                            END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                       ---------------------------------------------------------------------------------------------------------------------------------               
                       insert into @TempTable7(Sum123) values(@variable)
                       if(@variableBestEff > 1)
                       begin
                       set @variableBestEff = 1
                       end
                       insert into @TempTable8(SumBestEff) values(@variableBestEff)
                       set @variable=0.0
                       set @variableBestEff=0.0
                       SET @cnt = @cnt + 1;
                  END;
              ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable7
              
              declare @count123 int
              set @count123=1
              ---------------------------------------------------------------------------------------------------------------------------------------
                       DECLARE idCursor2 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Sum123 FROM @TempTable7
                       DECLARE @Values1234 [nchar](10)
                       OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @Values1234
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                  if(@count123 = 1)begin  set @T1= @Values1234   end if(@count123 = 2)begin set @T2= @Values1234  end
                                  if(@count123 = 3)begin  set @T3= @Values1234   end if(@count123 = 4)begin set @T4= @Values1234  end
                                  if(@count123 = 5)begin  set @T5= @Values1234   end if(@count123 = 6)begin set @T6= @Values1234  end
                                  if(@count123 = 7)begin  set @T7= @Values1234   end if(@count123 = 8)begin set @T8= @Values1234  end
                                  if(@count123 = 9)begin  set @T9= @Values1234   end if(@count123 = 10)begin set @T10= @Values1234  end
                                  if(@count123 = 11)begin set @T11= @Values1234  end if(@count123 = 12)begin set @T12= @Values1234  end
                                  if(@count123 = 13)begin set @T13= @Values1234  end if(@count123 = 14)begin set @T14= @Values1234  end
                                  if(@count123 = 15)begin set @T15= @Values1234  end if(@count123 = 16)begin set @T16= @Values1234  end
                                  if(@count123 = 17)begin set @T17= @Values1234  end if(@count123 = 18)begin set @T18= @Values1234  end
                                  if(@count123 = 19)begin set @T19= @Values1234  end if(@count123 = 20)begin set @T20= @Values1234  end
                                  if(@count123 = 21)begin set @T21= @Values1234  end if(@count123 = 22)begin set @T22= @Values1234  end
                                  if(@count123 = 23)begin set @T23= @Values1234  end if(@count123 = 24)begin set @T24= @Values1234  end
                                  if(@count123 = 25)begin set @T25= @Values1234  end if(@count123 = 26)begin set @T26= @Values1234  end
                                  if(@count123 = 27)begin set @T27= @Values1234  end if(@count123 = 28)begin set @T28= @Values1234  end
                                  if(@count123 = 29)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T29= 'NA' end
                                     else begin set @T29= @Values1234  end
                                  end
                                  if(@count123 = 30)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T30= 'NA' end
                                     else begin set @T30= @Values1234  end
                                  end
                                  if(@count123 = 31)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T31= 'NA' end
                                     else begin set @T31= @Values1234 end
                                  end

                                set @count123 =@count123+1
                                FETCH NEXT FROM idCursor2 INTO @Values1234
                            END
                       CLOSE idCursor2
                       DEALLOCATE idCursor2
              -----------------------------------------------------------------------------------------------------------------------------------------
              Declare @Effeciency float , @total float
              if (@T31 != 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )+cast(@T31 as float )
              end
              if (@T31 = 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 = 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )
              end
              declare @datestring nvarchar(20),@MonthNumDays float
              set @datestring= @Year+'-'+@Month+'-01'
              set @MonthNumDays=(select DAY(EOMONTH(@datestring)))
              set @Effeciency= (@total / @MonthNumDays) * 100
              set @BestPossibleEffeciency = ((select sum(SumBestEff) from @TempTable8)/@MonthNumDays) * 100

              set @Output=(select sum(ManDays) from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%');

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Effeciency(%)',CONVERT(DECIMAL(10,2),@Effeciency),'Assign',(select sum(ManDays) from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'),@T1,@T2,@T3,@T4,@T5,@T6,@T7,@T8,@T9,@T10,@T11,@T12,@T13,@T14,@T15,@T16,@T17,@T18,@T19,@T20,@T21,@T22,@T23,@T24,@T25,@T26,@T27,@T28,@T29,@T30,@T31)
--select * from @TempTable4
              declare @T29_1 nchar(10),@T30_1 nchar(10),@T31_1 nchar(10)           
              if(@T29 = 'NA') begin set @T29_1='NA' end
              else begin set @T29_1 = (1-cast(@T29 as float)) end
              if(@T30 = 'NA') begin set @T30_1='NA' end
              else begin set @T30_1 = (1-cast(@T30 as float)) end
              if(@T31 = 'NA') begin set @T31_1='NA' end
              else begin set @T31_1 = (1-cast(@T31 as float)) end

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Best Effeciency(%)',CONVERT(DECIMAL(10,2),@BestPossibleEffeciency),'Un-Assign',(1-cast(@T1 as float)),(1-cast(@T2 as float)),(1-cast(@T3 as float)),(1-cast(@T4 as float)),(1-cast(@T5 as float)),(1-cast(@T6 as float)),(1-cast(@T7 as float)),(1-cast(@T8 as float)),(1-cast(@T9 as float)),
              (1-cast(@T10 as float)),(1-cast(@T11 as float)),(1-cast(@T12 as float)),(1-cast(@T13 as float)),(1-cast(@T14 as float)),(1-cast(@T15 as float)),(1-cast(@T16 as float)),(1-cast(@T17 as float)),(1-cast(@T18 as float)),(1-cast(@T19 as float)),(1-cast(@T20 as float)),(1-cast(@T21 as float)),(1-cast(@T22 as float)),
              (1-cast(@T23 as float)),(1-cast(@T24 as float)),(1-cast(@T25 as float)),(1-cast(@T26 as float)),(1-cast(@T27 as float)),(1-cast(@T28 as float)),@T29_1,@T30_1,@T31_1)

              set @BestPossibleEffeciency=0.0
              delete from @TempTable7
              delete from @TempTable8
              FETCH NEXT FROM idCursor INTO @EmployeeID2
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     --select * from @TempTable4
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SupervisorWise_KK]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SupervisorWise_KK]    
(@SupervisorID NVARCHAR(max),@EmployeeName NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;

     declare @TempTable table ( EmployeeID nvarchar(50) )
     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10), [Remarks]  [nvarchar](max) 
     )

     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'  and EmployeeName like '%'+@EmployeeName+'%'
--select * from @TempTable
     declare @RecIdMD int
     
     
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID FROM @TempTable
     DECLARE @EmployeeID nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @SqlQuery nvarchar(500)
              set @SqlQuery='select RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],[ManDays],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] from tblMonthData where EmployeeID='+ @EmployeeID +' and PresentYear like ''%'+@Year+'%''' +' and PresentMonth ='''+@Month +''' order by ProjectID'
              insert into @TempTable1
              execute sp_sqlexec @SqlQuery
              
              FETCH NEXT FROM idCursor INTO @EmployeeID
         END
     CLOSE idCursor
     DEALLOCATE idCursor
--select * from @TempTable1

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) ,[Remarks]  [nvarchar](max) )

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),@Task nvarchar(150),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10),@Remarks nvarchar(max)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID
--select * from @TempTable3
              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'

              declare @PresentDays float, @counter int
              set @counter=1 
              set @PresentDays=0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 0.0

                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += @value321
                       End
                  Set @counter = @counter +1 
              End      
              insert into @TempTable2(RecId,EmployeeID,ProjectCode,[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectCode from @TempTable3),@Task,@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
         END
     CLOSE idCursor
     DEALLOCATE idCursor

--select * from @TempTable2

     declare @TempTable4 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](3)  ,[2] [nchar](3)  ,[3] [nchar](3)  ,[4] [nchar](3)  ,[5] [nchar](3)  ,[6] [nchar](3)  ,[7] [nchar](3) ,
     [8] [nchar](3)  ,[9] [nchar](3)  ,[10] [nchar](3) ,[11] [nchar](3) ,[12] [nchar](3) ,[13] [nchar](3) ,[14] [nchar](3) ,
     [15] [nchar](3) ,[16] [nchar](3) ,[17] [nchar](3) ,[18] [nchar](3) ,[19] [nchar](3) ,[20] [nchar](3) ,[21] [nchar](3) ,
     [22] [nchar](3) ,[23] [nchar](3) ,[24] [nchar](3) ,[25] [nchar](3) ,[26] [nchar](3) ,[27] [nchar](3) ,[28] [nchar](3) ,
     [29] [nchar](3) ,[30] [nchar](3) ,[31] [nchar](3),[Remarks]  [nvarchar](max) )
     
     declare @TempTable7 table ( Sum123 [nchar](10) )
     declare @TempTable8 table ( SumBestEff float)
     declare @BestPossibleEffeciency float
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT distinct EmployeeID FROM @TempTable1
     DECLARE @EmployeeID2 nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID2
     WHILE @@FETCH_STATUS=0
         BEGIN
              insert into @TempTable4
              select * from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'
              declare @T1 nchar(10),@T2 nchar(10),@T3 nchar(10),@T4 nchar(10),@T5 nchar(10),@T6 nchar(10),@T7 nchar(10),@T8 nchar(10),@T9 nchar(10),@T10 nchar(10),@T11 nchar(10),@T12 nchar(10),
                       @T13 nchar(10),@T14 nchar(10),@T15 nchar(10),@T16 nchar(10),@T17 nchar(10),@T18 nchar(10),@T19 nchar(10),@T20 nchar(10),@T21 nchar(10),@T22 nchar(10),@T23 nchar(10),
                       @T24 nchar(10),@T25 nchar(10),@T26 nchar(10),@T27 nchar(10),@T28 nchar(10),@T29 nchar(10),@T30 nchar(10),@T31 nchar(10)
              -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                  declare @TempTable6 table ( Values321 [nchar](10) )
                  DECLARE @cnt INT = 1;
                  WHILE @cnt < 32
                  BEGIN
                  delete from @TempTable6
                  declare @SqlQuery2 nvarchar(200)
                       set @SqlQuery2='select ['+cast(@cnt as nvarchar(20))+'] from tblMonthData where EmployeeID ='+ cast(@EmployeeID2 as varchar(50)) +' and PresentMonth ='''+ cast(@Month as nvarchar(20)) +'''and PresentYear = '+ cast(@Year as nvarchar(20))
                       insert into @TempTable6
                       execute sp_sqlexec @SqlQuery2
                       Declare @variable float
                       set @variable=0.0 
                       Declare @variableBestEff float
                       set @variableBestEff=0.0 
                       --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable6               
                       DECLARE idCursor1 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Values321 FROM @TempTable6
                       DECLARE @Values123 [nchar](10)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @Values123
                       WHILE @@FETCH_STATUS=0
                            BEGIN
         
                                     declare @C1 float = (select count(*) from @TempTable6)     
                                          
                                     if(@Values123 = 'A')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += (1.0/@C1)
                                          --break;
                                     end
                                     if(@Values123 = 'WO' or @Values123 = 'PH' or @Values123 = 'C')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += 0.0
                                     end
                                     else if( @Values123 != 'P' and @Values123 != 'WO' and @Values123 != 'PH' and @Values123 != 'C' and @Values123 != 'A' and @Values123 != 'NA')
                                     begin
                                          set @variable += (select cast(@Values123 as float))
                                          set @variableBestEff += 1   --(select cast(@Values123 as float))
                                     end
                                     else if( @Values123 = 'P')
                                     begin 
                                          set @variable +=0.0
                                          set @variableBestEff += (1.0/@C1)
                                     end
                                     else if( @Values123 = 'NA')
                                     begin 
                                          set @variable =0.03
                                          set @variableBestEff += 0
                                     end

                                FETCH NEXT FROM idCursor1 INTO @Values123
                            END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                       ---------------------------------------------------------------------------------------------------------------------------------               
                       insert into @TempTable7(Sum123) values(@variable)
                       if(@variableBestEff > 1)
                       begin
                       set @variableBestEff = 1
                       end
                       insert into @TempTable8(SumBestEff) values(@variableBestEff)
                       set @variable=0.0
                       set @variableBestEff=0.0
                       SET @cnt = @cnt + 1;
                  END;
              ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable7
              
              declare @count123 int
              set @count123=1
              ---------------------------------------------------------------------------------------------------------------------------------------
                       DECLARE idCursor2 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Sum123 FROM @TempTable7
                       DECLARE @Values1234 [nchar](10)
                       OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @Values1234
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                  if(@count123 = 1)begin  set @T1= @Values1234   end if(@count123 = 2)begin set @T2= @Values1234  end
                                  if(@count123 = 3)begin  set @T3= @Values1234   end if(@count123 = 4)begin set @T4= @Values1234  end
                                  if(@count123 = 5)begin  set @T5= @Values1234   end if(@count123 = 6)begin set @T6= @Values1234  end
                                  if(@count123 = 7)begin  set @T7= @Values1234   end if(@count123 = 8)begin set @T8= @Values1234  end
                                  if(@count123 = 9)begin  set @T9= @Values1234   end if(@count123 = 10)begin set @T10= @Values1234  end
                                  if(@count123 = 11)begin set @T11= @Values1234  end if(@count123 = 12)begin set @T12= @Values1234  end
                                  if(@count123 = 13)begin set @T13= @Values1234  end if(@count123 = 14)begin set @T14= @Values1234  end
                                  if(@count123 = 15)begin set @T15= @Values1234  end if(@count123 = 16)begin set @T16= @Values1234  end
                                  if(@count123 = 17)begin set @T17= @Values1234  end if(@count123 = 18)begin set @T18= @Values1234  end
                                  if(@count123 = 19)begin set @T19= @Values1234  end if(@count123 = 20)begin set @T20= @Values1234  end
                                  if(@count123 = 21)begin set @T21= @Values1234  end if(@count123 = 22)begin set @T22= @Values1234  end
                                  if(@count123 = 23)begin set @T23= @Values1234  end if(@count123 = 24)begin set @T24= @Values1234  end
                                  if(@count123 = 25)begin set @T25= @Values1234  end if(@count123 = 26)begin set @T26= @Values1234  end
                                  if(@count123 = 27)begin set @T27= @Values1234  end if(@count123 = 28)begin set @T28= @Values1234  end
                                  if(@count123 = 29)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T29= 'NA' end
                                     else begin set @T29= @Values1234  end
                                  end
                                  if(@count123 = 30)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T30= 'NA' end
                                     else begin set @T30= @Values1234  end
                                  end
                                  if(@count123 = 31)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T31= 'NA' end
                                     else begin set @T31= @Values1234 end
                                  end

                                set @count123 =@count123+1
                                FETCH NEXT FROM idCursor2 INTO @Values1234
                            END
                       CLOSE idCursor2
                       DEALLOCATE idCursor2
              -----------------------------------------------------------------------------------------------------------------------------------------
              Declare @Effeciency float , @total float
              if (@T31 != 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )+cast(@T31 as float )
              end
              if (@T31 = 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 = 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )
              end
              declare @datestring nvarchar(20),@MonthNumDays float
              set @datestring= @Year+'-'+@Month+'-01'
              set @MonthNumDays=(select DAY(EOMONTH(@datestring)))
              set @Effeciency= (@total / @MonthNumDays) * 100
              set @BestPossibleEffeciency = ((select sum(SumBestEff) from @TempTable8)/@MonthNumDays) * 100

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Effeciency(%)',CONVERT(DECIMAL(10,2),@Effeciency),'Assign',CONVERT(DECIMAL(10,2),(select sum(ManDays) from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%')),@T1,@T2,@T3,@T4,@T5,@T6,@T7,@T8,@T9,@T10,@T11,@T12,@T13,@T14,@T15,@T16,@T17,@T18,@T19,@T20,@T21,@T22,@T23,@T24,@T25,@T26,@T27,@T28,@T29,@T30,@T31)
--select * from @TempTable4
              declare @T29_1 nchar(10),@T30_1 nchar(10),@T31_1 nchar(10)           
              if(@T29 = 'NA') begin set @T29_1='NA' end
              else begin set @T29_1 = (1-cast(@T29 as float)) end
              if(@T30 = 'NA') begin set @T30_1='NA' end
              else begin set @T30_1 = (1-cast(@T30 as float)) end
              if(@T31 = 'NA') begin set @T31_1='NA' end
              else begin set @T31_1 = (1-cast(@T31 as float)) end

              insert into @TempTable4(EmployeeID,[ProjectCode],[Task],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
              values ('Best Effeciency(%)',CONVERT(DECIMAL(10,2),@BestPossibleEffeciency),'Un-Assign',(1-cast(@T1 as float)),(1-cast(@T2 as float)),(1-cast(@T3 as float)),(1-cast(@T4 as float)),(1-cast(@T5 as float)),(1-cast(@T6 as float)),(1-cast(@T7 as float)),(1-cast(@T8 as float)),(1-cast(@T9 as float)),
              (1-cast(@T10 as float)),(1-cast(@T11 as float)),(1-cast(@T12 as float)),(1-cast(@T13 as float)),(1-cast(@T14 as float)),(1-cast(@T15 as float)),(1-cast(@T16 as float)),(1-cast(@T17 as float)),(1-cast(@T18 as float)),(1-cast(@T19 as float)),(1-cast(@T20 as float)),(1-cast(@T21 as float)),(1-cast(@T22 as float)),
              (1-cast(@T23 as float)),(1-cast(@T24 as float)),(1-cast(@T25 as float)),(1-cast(@T26 as float)),(1-cast(@T27 as float)),(1-cast(@T28 as float)),@T29_1,@T30_1,@T31_1)

              set @BestPossibleEffeciency=0.0
              delete from @TempTable7
              delete from @TempTable8
              FETCH NEXT FROM idCursor INTO @EmployeeID2
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     select * from @TempTable4
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spInsert_SupervisorWise_Overall]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsert_SupervisorWise_Overall]    
(@SupervisorID NVARCHAR(max),@EmployeeName NVARCHAR(max),@Month NVARCHAR(max),@Year NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     EXEC spInsert_SetHoliday;


	 declare @TempTableTest table([Employee Name] [nvarchar](max),[Employee ID] [nvarchar](max),[Supervisor Name] [nvarchar](max),[Effeciency(%)] [nvarchar](max),[Best Effeciency(%)] [nvarchar](max), [Assigned] [nvarchar](max),[Total Days] [nvarchar](max))

     declare @TempTable table ( EmployeeID nvarchar(50) )
     declare @TempTable1 table ( 
     [RecId] [bigint], 
     [EmployeeID] [nvarchar](50),[ProjectID] [bigint],[PresentMonth] [nvarchar](50),[PresentYear] [nvarchar](50) , [Task] [nvarchar](150),[ManDays] int,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10), [Remarks]  [nvarchar](max) 
     )

     insert into @TempTable
     select EmployeeID from tblEmployee where DirectSupervisor like '%'+@SupervisorID+'%'  and EmployeeName like '%'+@EmployeeName+'%'
--select * from @TempTable
     declare @RecIdMD int
     
     
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID FROM @TempTable
     DECLARE @EmployeeID nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @SqlQuery nvarchar(500)
              set @SqlQuery='select RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],[ManDays],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] from tblMonthData where EmployeeID='+ @EmployeeID +' and PresentYear like ''%'+@Year+'%''' +' and PresentMonth ='''+@Month +''' order by ProjectID'
              insert into @TempTable1
              execute sp_sqlexec @SqlQuery
              
              FETCH NEXT FROM idCursor INTO @EmployeeID
         END
     CLOSE idCursor
     DEALLOCATE idCursor
--select * from @TempTable1

     declare @TempTable2 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10) ,[Remarks]  [nvarchar](max) )

     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  RecId,EmployeeID ,ProjectID ,PresentMonth,PresentYear,[Task],
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks] FROM @TempTable1
     DECLARE @RecId bigint,@EmployeeID1 nvarchar(50) ,@ProjectID bigint ,@PresentMonth nvarchar(50),@PresentYear nvarchar(50),@Task nvarchar(150),
     @1 nchar(10),@2 nchar(10),@3 nchar(10),@4 nchar(10),@5 nchar(10),@6 nchar(10),@7 nchar(10),@8 nchar(10),@9 nchar(10),@10 nchar(10),@11 nchar(10),@12 nchar(10),
     @13 nchar(10),@14 nchar(10),@15 nchar(10),@16 nchar(10),@17 nchar(10),@18 nchar(10),@19 nchar(10),@20 nchar(10),@21 nchar(10),@22 nchar(10),@23 nchar(10),
     @24 nchar(10),@25 nchar(10),@26 nchar(10),@27 nchar(10),@28 nchar(10),@29 nchar(10),@30 nchar(10),@31 nchar(10),@Remarks nvarchar(max)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
     WHILE @@FETCH_STATUS=0
         BEGIN
              declare @TempTable3 table(ProjectName nvarchar(max),ProjectCode nvarchar(50))
              insert into @TempTable3
              select ProjectName,ProjectCode from tblProject where ProjectID= @ProjectID
--select * from @TempTable3
              DECLARE @EmpNameID nvarchar(100)
              set @EmpNameID = (select EmployeeName from tblEmployee where EmployeeID=@EmployeeID1) +' (' +(@EmployeeID1) +')'

              declare @PresentDays float, @counter int
              set @counter=1 
              set @PresentDays=0
              While (@counter < 32)
              Begin
              Declare @value321 nvarchar(20),@query1 nvarchar(300)
              set @query1='select @value321=['+cast(@counter as nvarchar(10))+'] FROM tblMonthData where RecId='+ cast(@RecId as nvarchar(50))
              EXECUTE sp_executesql @Query=@query1 , 
                       @Params = N'@value321 NVARCHAR(20) OUTPUT',
                       @value321= @value321 OUTPUT  

                  If (@value321 = 'P') 
                       Begin
                            Set @PresentDays += 0.0

                       End
                  else If (@value321 != 'P' and @value321 != 'WO' and @value321 != 'C' and @value321 != 'PH' and @value321 != 'A' and @value321 != 'NA')
                       Begin
                            Set @PresentDays += @value321
                       End
                  Set @counter = @counter +1 
              End      
              insert into @TempTable2(RecId,EmployeeID,ProjectCode,[Task],ManDays,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[Remarks]) 
              values(@RecId,@EmpNameID,(select top(1) ProjectCode from @TempTable3),@Task,@PresentDays,
         @1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks)

              delete from @TempTable3;

              FETCH NEXT FROM idCursor INTO @RecId,@EmployeeID1,@ProjectID,@PresentMonth,@PresentYear,@Task,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,@Remarks
         END
     CLOSE idCursor
     DEALLOCATE idCursor

--select * from @TempTable2

     declare @TempTable4 table ( 
     [RecId] [bigint], [EmployeeID] [nvarchar](max),[ProjectCode] [nvarchar](max), [Task] [nvarchar](150),[ManDays] float,
     [1] [nchar](10)  ,[2] [nchar](10)  ,[3] [nchar](10)  ,[4] [nchar](10)  ,[5] [nchar](10)  ,[6] [nchar](10)  ,[7] [nchar](10) ,
     [8] [nchar](10)  ,[9] [nchar](10)  ,[10] [nchar](10) ,[11] [nchar](10) ,[12] [nchar](10) ,[13] [nchar](10) ,[14] [nchar](10) ,
     [15] [nchar](10) ,[16] [nchar](10) ,[17] [nchar](10) ,[18] [nchar](10) ,[19] [nchar](10) ,[20] [nchar](10) ,[21] [nchar](10) ,
     [22] [nchar](10) ,[23] [nchar](10) ,[24] [nchar](10) ,[25] [nchar](10) ,[26] [nchar](10) ,[27] [nchar](10) ,[28] [nchar](10) ,
     [29] [nchar](10) ,[30] [nchar](10) ,[31] [nchar](10),[Remarks]  [nvarchar](max) )
     
     declare @TempTable7 table ( Sum123 [nchar](10) )
     declare @TempTable8 table ( SumBestEff float)
     declare @BestPossibleEffeciency float
     DECLARE idCursor CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT distinct EmployeeID FROM @TempTable1
     DECLARE @EmployeeID2 nvarchar(50)
     OPEN idCursor FETCH NEXT FROM idCursor INTO @EmployeeID2
     WHILE @@FETCH_STATUS=0
         BEGIN
              insert into @TempTable4
              select * from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'
              declare @T1 nchar(10),@T2 nchar(10),@T3 nchar(10),@T4 nchar(10),@T5 nchar(10),@T6 nchar(10),@T7 nchar(10),@T8 nchar(10),@T9 nchar(10),@T10 nchar(10),@T11 nchar(10),@T12 nchar(10),
                       @T13 nchar(10),@T14 nchar(10),@T15 nchar(10),@T16 nchar(10),@T17 nchar(10),@T18 nchar(10),@T19 nchar(10),@T20 nchar(10),@T21 nchar(10),@T22 nchar(10),@T23 nchar(10),
                       @T24 nchar(10),@T25 nchar(10),@T26 nchar(10),@T27 nchar(10),@T28 nchar(10),@T29 nchar(10),@T30 nchar(10),@T31 nchar(10)
              -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                  declare @TempTable6 table ( Values321 [nchar](10) )
                  DECLARE @cnt INT = 1;
                  WHILE @cnt < 32
                  BEGIN
                  delete from @TempTable6
                  declare @SqlQuery2 nvarchar(200)
                       set @SqlQuery2='select ['+cast(@cnt as nvarchar(20))+'] from tblMonthData where EmployeeID ='+ cast(@EmployeeID2 as varchar(50)) +' and PresentMonth ='''+ cast(@Month as nvarchar(20)) +'''and PresentYear = '+ cast(@Year as nvarchar(20))
                       insert into @TempTable6
                       execute sp_sqlexec @SqlQuery2
                       Declare @variable float
                       set @variable=0.0 
                       Declare @variableBestEff float
                       set @variableBestEff=0.0 
                       --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable6               
                       DECLARE idCursor1 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Values321 FROM @TempTable6
                       DECLARE @Values123 [nchar](10)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @Values123
                       WHILE @@FETCH_STATUS=0
                            BEGIN
         
                                     declare @C1 float = (select count(*) from @TempTable6)     
                                          
                                     if(@Values123 = 'A')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += (1.0/@C1)
                                          --break;
                                     end
                                     if(@Values123 = 'WO' or @Values123 = 'PH' or @Values123 = 'C')
                                     begin
                                          set @variable += 0.0
                                          set @variableBestEff += 0.0
                                     end
                                     else if( @Values123 != 'P' and @Values123 != 'WO' and @Values123 != 'PH' and @Values123 != 'C' and @Values123 != 'A' and @Values123 != 'NA')
                                     begin
                                          set @variable += (select cast(@Values123 as float))
                                          set @variableBestEff += 1   --(select cast(@Values123 as float))
                                     end
                                     else if( @Values123 = 'P')
                                     begin 
                                          set @variable +=0.0
                                          set @variableBestEff += (1.0/@C1)
                                     end
                                     else if( @Values123 = 'NA')
                                     begin 
                                          set @variable =0.03
                                          set @variableBestEff += 0
                                     end

                                FETCH NEXT FROM idCursor1 INTO @Values123
                            END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                       ---------------------------------------------------------------------------------------------------------------------------------               
                       insert into @TempTable7(Sum123) values(@variable)
                       if(@variableBestEff > 1)
                       begin
                       set @variableBestEff = 1
                       end
                       insert into @TempTable8(SumBestEff) values(@variableBestEff)
                       set @variable=0.0
                       set @variableBestEff=0.0
                       SET @cnt = @cnt + 1;
                  END;
              ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable7
              
              declare @count123 int
              set @count123=1
              ---------------------------------------------------------------------------------------------------------------------------------------
                       DECLARE idCursor2 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Sum123 FROM @TempTable7
                       DECLARE @Values1234 [nchar](10)
                       OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @Values1234
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                  if(@count123 = 1)begin  set @T1= @Values1234   end if(@count123 = 2)begin set @T2= @Values1234  end
                                  if(@count123 = 3)begin  set @T3= @Values1234   end if(@count123 = 4)begin set @T4= @Values1234  end
                                  if(@count123 = 5)begin  set @T5= @Values1234   end if(@count123 = 6)begin set @T6= @Values1234  end
                                  if(@count123 = 7)begin  set @T7= @Values1234   end if(@count123 = 8)begin set @T8= @Values1234  end
                                  if(@count123 = 9)begin  set @T9= @Values1234   end if(@count123 = 10)begin set @T10= @Values1234  end
                                  if(@count123 = 11)begin set @T11= @Values1234  end if(@count123 = 12)begin set @T12= @Values1234  end
                                  if(@count123 = 13)begin set @T13= @Values1234  end if(@count123 = 14)begin set @T14= @Values1234  end
                                  if(@count123 = 15)begin set @T15= @Values1234  end if(@count123 = 16)begin set @T16= @Values1234  end
                                  if(@count123 = 17)begin set @T17= @Values1234  end if(@count123 = 18)begin set @T18= @Values1234  end
                                  if(@count123 = 19)begin set @T19= @Values1234  end if(@count123 = 20)begin set @T20= @Values1234  end
                                  if(@count123 = 21)begin set @T21= @Values1234  end if(@count123 = 22)begin set @T22= @Values1234  end
                                  if(@count123 = 23)begin set @T23= @Values1234  end if(@count123 = 24)begin set @T24= @Values1234  end
                                  if(@count123 = 25)begin set @T25= @Values1234  end if(@count123 = 26)begin set @T26= @Values1234  end
                                  if(@count123 = 27)begin set @T27= @Values1234  end if(@count123 = 28)begin set @T28= @Values1234  end
                                  if(@count123 = 29)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T29= 'NA' end
                                     else begin set @T29= @Values1234  end
                                  end
                                  if(@count123 = 30)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T30= 'NA' end
                                     else begin set @T30= @Values1234  end
                                  end
                                  if(@count123 = 31)
                                  begin 
                                     if(@Values1234 = cast(0.03 as [nchar](10)))begin  set @T31= 'NA' end
                                     else begin set @T31= @Values1234 end
                                  end

                                set @count123 =@count123+1
                                FETCH NEXT FROM idCursor2 INTO @Values1234
                            END
                       CLOSE idCursor2
                       DEALLOCATE idCursor2
              -----------------------------------------------------------------------------------------------------------------------------------------
              Declare @Effeciency float , @total float
              if (@T31 != 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )+cast(@T31 as float )
              end
              if (@T31 = 'NA' and @T30 != 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )+cast(@T30 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 != 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )+cast(@T29 as float )
              end
              if (@T31 = 'NA' and @T30 = 'NA' and @T29 = 'NA')
              begin
              set @total=cast(@T1 as float )+cast(@T2 as float )+cast(@T3 as float )+cast(@T4 as float )+cast(@T5 as float )+cast(@T6 as float )+cast(@T7 as float )+cast(@T8 as float )+cast(@T9 as float )+cast(@T10 as float )+cast(@T11 as float )+cast(@T12 as float )+cast(@T13 as float )+cast(@T14 as float )+cast(@T15 as float )+cast(@T16 as float )+cast(@T17 as float )+cast(@T18 as float )+cast(@T19 as float )+cast(@T20 as float )+cast(@T21 as float )+cast(@T22 as float )+cast(@T23 as float )+cast(@T24 as float )+cast(@T25 as float )+cast(@T26 as float )+cast(@T27 as float )+cast(@T28 as float )
              end
              declare @datestring nvarchar(20),@MonthNumDays float
              set @datestring= @Year+'-'+@Month+'-01'
              set @MonthNumDays=(select DAY(EOMONTH(@datestring)))
              set @Effeciency= (@total / @MonthNumDays) * 100
              set @BestPossibleEffeciency = ((select sum(SumBestEff) from @TempTable8)/@MonthNumDays) * 100

              declare @T29_1 nchar(10),@T30_1 nchar(10),@T31_1 nchar(10)           
              if(@T29 = 'NA') begin set @T29_1='NA' end
              else begin set @T29_1 = (1-cast(@T29 as float)) end
              if(@T30 = 'NA') begin set @T30_1='NA' end
              else begin set @T30_1 = (1-cast(@T30 as float)) end
              if(@T31 = 'NA') begin set @T31_1='NA' end
              else begin set @T31_1 = (1-cast(@T31 as float)) end

			  insert into @TempTableTest values (@EmployeeName,(select top(1) EmployeeID from @TempTable),@SupervisorID,CONVERT(DECIMAL(10,2),@Effeciency),CONVERT(DECIMAL(10,2),@BestPossibleEffeciency),(select sum(ManDays) from @TempTable2 where EmployeeID like '%'+ @EmployeeID2 +'%'),(select sum(SumBestEff) from @TempTable8))

              set @BestPossibleEffeciency=0.0
              delete from @TempTable7
              delete from @TempTable8
              FETCH NEXT FROM idCursor INTO @EmployeeID2
         END
     CLOSE idCursor
     DEALLOCATE idCursor

     --select * from @TempTable4
	 select * from @TempTableTest
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spProjectMaster]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spProjectMaster]    
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
	 select RecId,ProjectCode,ProjectName,ProjectType,cast(ProjectStartDate as nvarchar(20)) as ProjectStartDate,cast(ProjectEndDate as nvarchar(20)) as ProjectEndDate,cast(OldProjectEndDate as nvarchar(20)) as OldProjectEndDate from tblProject

	 --cast(@DateComplaint as nvarchar(20))
COMMIT TRANSACTION
END TRY

BEGIN CATCH
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorMessage NVARCHAR(4000)

-- Get error text
SET @ErrorSeverity = ERROR_SEVERITY()
SET @ErrorState = ERROR_STATE()
SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

IF (XACT_STATE() = -1)
BEGIN
     ROLLBACK TRANSACTION;
END

IF (XACT_STATE() = 1)
BEGIN
     COMMIT TRANSACTION;
END

RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

END CATCH













GO
/****** Object:  StoredProcedure [dbo].[spShow_ProjectName]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spShow_ProjectName]    
(@EmpId NVARCHAR(max),@Year NVARCHAR(max),@Month NVARCHAR(max))
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
BEGIN TRANSACTION
BEGIN TRY
     
     --EXEC spInsert_SetHoliday;

     select ProjectCode +' ( '+ProjectName+')' as ProjectName  from tblProject where ProjectID in (select ProjectID from tblMonthData where EmployeeID=@EmpId and PresentMonth like'%'+@Month+'%' and PresentYear like '%'+@Year+'%') 
         
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spUpdate_tblMonthData]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdate_tblMonthData]   
(@RecID bigint, @c5 nchar(10), @c6 nchar(10), @c7 nchar(10), @c8 nchar(10), @c9 nchar(10), @c10 nchar(10), @c11 nchar(10), @c12 nchar(10), @c13 nchar(10), @c14 nchar(10),
@c15 nchar(10), @c16 nchar(10), @c17 nchar(10), @c18 nchar(10), @c19 nchar(10), @c20 nchar(10), @c21 nchar(10), @c22 nchar(10), @c23 nchar(10), @c24 nchar(10), @c25 nchar(10), @c26 nchar(10),
@c27 nchar(10), @c28 nchar(10), @c29 nchar(10), @c30 nchar(10), @c31 nchar(10), @c32 nchar(10), @c33 nchar(10), @c34 nchar(10),@c35 nchar(10)) 
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY

     -----------------------------------------------------------------------------------------------
         declare @EmployeeID nvarchar(50),@PresentMonth nvarchar(50) ,@PresentYear nvarchar(50)
         set @EmployeeID   =(SELECT EmployeeID FROM tblMonthData where RecId=@RecID)
         set @PresentMonth =(SELECT PresentMonth FROM tblMonthData where RecId=@RecID)
         set @PresentYear  =(SELECT PresentYear FROM tblMonthData where RecId=@RecID)

         declare @OldvalueCount int, @nv nvarchar(10)
         set @OldvalueCount=5
         declare @datestring nvarchar(20),@MonthNumDays float
         set @datestring= @PresentYear+'-'+@PresentMonth+'-01'
         set @MonthNumDays=(select DAY(EOMONTH(@datestring)))

         declare @TempTable table (columnName int,OldValue nchar(10),NewValue nchar(10),DiffON nchar(10),TotalOld nchar(10),MaxTotal nchar(10),DiffTM nchar(10))
         declare @TempTable6 table ( Values321 [nchar](10) )
                  DECLARE @cnt INT = 1;
                  WHILE @cnt <= @MonthNumDays
                  BEGIN
						  delete from @TempTable6
						  declare @SqlQuery nvarchar(200),@SqlQuery1 nvarchar(200)

                       set @SqlQuery='select ['+cast(@cnt as nvarchar(20))+'] from tblMonthData where EmployeeID ='+ cast(@EmployeeID as varchar(50)) +' and PresentMonth ='''+ cast(@PresentMonth as nvarchar(20)) +'''and PresentYear = '+ cast(@PresentYear as nvarchar(20))
                       insert into @TempTable6
                       execute sp_sqlexec @SqlQuery

                       set @SqlQuery1='select @OldValue=['+cast(@cnt as nvarchar(20))+'] from tblMonthData where RecID='+cast(@RecID as nvarchar(50)) 
                       Declare @OldValue nchar(10)
                       EXECUTE sp_executesql @Query=@SqlQuery1 , 
                       @Params = N'@OldValue nchar(10) OUTPUT',
                       @OldValue= @OldValue OUTPUT 

                       if(@OldValue ='P' or @OldValue ='WO' or @OldValue ='C' or @OldValue ='PH' or @OldValue ='A')
                       begin
                       set @OldValue=0
                       end

                       Declare @variable float
                       set @variable=0.0 
                       --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from @TempTable6
                       DECLARE idCursor1 CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  Values321 FROM @TempTable6
                       DECLARE @Values123 [nchar](10)
                       OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @Values123
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                     if(@Values123 = 'WO' or @Values123 = 'PH' or @Values123 = 'C' or @Values123 = 'A')
                                     begin
                                          set @variable = 0.0
                                          break;
                                     end
                                     else if( @Values123 != 'P' and @Values123 != 'WO' and @Values123 != 'PH' and @Values123 != 'C' and @Values123 != 'A' and @Values123 != 'NA')
                                     begin
                                          set @variable += (select cast(@Values123 as float))
                                     end
                                     else if( @Values123 = 'P')
                                     begin 
                                          set @variable +=0.0
                                     end
                                     else if( @Values123 = 'NA')
                                     begin 
                                          set @variable =0.03
                                     end

                                FETCH NEXT FROM idCursor1 INTO @Values123
                            END
                       CLOSE idCursor1
                       DEALLOCATE idCursor1
                       ---------------------------------------------------------------------------------------------------------------------------------
                       if(@OldvalueCount = 5)begin set @nv=@c5 end
                       if(@OldvalueCount = 6)begin set @nv=@c6 end
                       if(@OldvalueCount = 7)begin set @nv=@c7 end
                       if(@OldvalueCount = 8)begin set @nv=@c8 end
                       if(@OldvalueCount = 9)begin set @nv=@c9 end
                       if(@OldvalueCount = 10)begin set @nv=@c10 end
                       if(@OldvalueCount = 11)begin set @nv=@c11 end
                       if(@OldvalueCount = 12)begin set @nv=@c12 end
                       if(@OldvalueCount = 13)begin set @nv=@c13 end
                       if(@OldvalueCount = 14)begin set @nv=@c14 end
                       if(@OldvalueCount = 15)begin set @nv=@c15 end
                       if(@OldvalueCount = 16)begin set @nv=@c16 end
                       if(@OldvalueCount = 17)begin set @nv=@c17 end
                       if(@OldvalueCount = 18)begin set @nv=@c18 end
                       if(@OldvalueCount = 19)begin set @nv=@c19 end
                       if(@OldvalueCount = 20)begin set @nv=@c20 end
                       if(@OldvalueCount = 21)begin set @nv=@c21 end
                       if(@OldvalueCount = 22)begin set @nv=@c22 end
                       if(@OldvalueCount = 23)begin set @nv=@c23 end
                       if(@OldvalueCount = 24)begin set @nv=@c24 end
                       if(@OldvalueCount = 25)begin set @nv=@c25 end
                       if(@OldvalueCount = 26)begin set @nv=@c26 end
                       if(@OldvalueCount = 27)begin set @nv=@c27 end
                       if(@OldvalueCount = 28)begin set @nv=@c28 end
                       if(@OldvalueCount = 29)begin set @nv=@c29 end
                       if(@OldvalueCount = 30)begin set @nv=@c30 end
                       if(@OldvalueCount = 31)begin set @nv=@c31 end
                       if(@OldvalueCount = 32)begin set @nv=@c32 end
                       if(@OldvalueCount = 33)begin set @nv=@c33 end
                       if(@OldvalueCount = 34)begin set @nv=@c34 end
                       if(@OldvalueCount = 35)begin set @nv=@c35 end
                       
                       if(@nv ='P' or @nv ='WO' or @nv ='C' or @nv ='PH' or @nv ='A')
                       begin
                       set @nv=0
                       end

                       declare @DiffON nchar(10)
                       if(cast(@OldValue as float) > cast(@nv as float))
                       set @DiffON = cast(@nv as float) - cast(@OldValue as float)
                       else if(cast(@OldValue as float) < cast(@nv as float))
                       set @DiffON = cast(@nv as float) - cast(@OldValue as float)
                       else if(cast(@OldValue as float) = cast(@nv as float))
                       set @DiffON = 0

                       insert into @TempTable(columnName,OldValue,NewValue,DiffON,TotalOld,MaxTotal,DiffTM) values(@cnt,@OldValue,@nv,@DiffON,@variable,'1',(1.0-@variable))

                       set @variable=0.0
                       set @OldvalueCount = @OldvalueCount + 1
                       SET @cnt = @cnt + 1;
                       set @nv=''
                  END;
                  -------------------------------------------------------------------------------------------------------------------------------------
                  declare @TempTable1 table (columnName int,Result nchar(10))
                  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      
                       DECLARE idCursor CURSOR                    
                       LOCAL FORWARD_ONLY FAST_FORWARD           
                       FOR SELECT  columnName,DiffON,DiffTM FROM @TempTable
                       DECLARE @columnName [nchar](10),@DiffON1 [nchar](10),@DiffTM1 [nchar](10)
                       OPEN idCursor FETCH NEXT FROM idCursor INTO @columnName,@DiffON1,@DiffTM1
                       WHILE @@FETCH_STATUS=0
                            BEGIN
                                     if((cast(@DiffON1 as float) = cast(@DiffTM1 as float)) or (cast(@DiffON1 as float) < cast(@DiffTM1 as float)))
                                     begin
                                     insert into @TempTable1(columnName,Result) values(@columnName,'CHANGE')
                                     end
                                     else if((cast(@DiffON1 as float) > cast(@DiffTM1 as float)))
                                     begin
                                     insert into @TempTable1(columnName,Result) values(@columnName,'NoCHANGE')
                                     end

                                FETCH NEXT FROM idCursor INTO @columnName,@DiffON1,@DiffTM1
                            END
                       CLOSE idCursor
                       DEALLOCATE idCursor
-----------------------------------------------------------------------------------------------
                       select * from @TempTable1
-----------------------------------------------------------------------------------------------
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[spUpdate_tblMonthData1]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdate_tblMonthData1]   
(@RecID bigint, @c5 nchar(10), @c6 nchar(10), @c7 nchar(10), @c8 nchar(10), @c9 nchar(10), @c10 nchar(10), @c11 nchar(10), @c12 nchar(10), @c13 nchar(10), @c14 nchar(10),
@c15 nchar(10), @c16 nchar(10), @c17 nchar(10), @c18 nchar(10), @c19 nchar(10), @c20 nchar(10), @c21 nchar(10), @c22 nchar(10), @c23 nchar(10), @c24 nchar(10), @c25 nchar(10), @c26 nchar(10),
@c27 nchar(10), @c28 nchar(10), @c29 nchar(10), @c30 nchar(10), @c31 nchar(10), @c32 nchar(10), @c33 nchar(10), @c34 nchar(10),@c35 nchar(10),@c36 nvarchar(max)) 
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY

     -------------------------------------------------------
     update tblMonthData set [1]=@c5 , [2]=@c6 ,[3]=@c7 ,[4]=@c8 ,[5]=@c9 ,[6]=@c10 ,[7]=@c11 ,[8]=@c12 ,[9]=@c13 ,[10]=@c14 ,[11]=@c15 ,[12]=@c16 ,[13]=@c17 ,[14]=@c18 ,[15]=@c19 ,[16]=@c20,
     [17]=@c21 ,[18]=@c22 ,[19]=@c23 ,[20]=@c24 ,[21]=@c25 ,[22]=@c26 ,[23]=@c27 ,[24]=@c28 ,[25]=@c29 ,[26]=@c30 ,[27]=@c31 ,[28]=@c32 ,[29]=@c33 ,[30]=@c34 ,[31]=@c35 ,[Remarks]=@c36
     where RecId = @RecID
     -------------------------------------------------------

     

     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  StoredProcedure [dbo].[TEST_spInsert_SetHoliday]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TEST_spInsert_SetHoliday]    
AS 
     SET NOCOUNT ON;
     SET XACT_ABORT ON;
     BEGIN TRANSACTION
     BEGIN TRY
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @TempTable TABLE (  DateOfHoliday      date  ,DayOfWeek1 nvarchar(100))

     Insert into @TempTable
	 --- *********************************************
	 --- CHANGES FOR THE OPTIMIZATION OF QUERY
	 --- *********************************************
     select DateOfHoliday,DayOfWeek1 from tblHolidayCalander WHERE DATENAME(YYYY,DateOfHoliday)>=DATENAME(YYYY,GETDATE())

     select * from @TempTable

     
     DECLARE @DateOfHoliday date , @DayOfWeek1 nvarchar(100)
   
                  declare @month nvarchar(10),@year nvarchar(10),@Day nvarchar(10)
                  set @month=(select DATENAME(MM,@DateOfHoliday))
                  set @year=(select DATENAME(YYYY,@DateOfHoliday))
                  set @Day=(select DATENAME(DD,@DateOfHoliday))
                  
                  -------------------------------------------------------------------------------------------------- 
                  DECLARE @TempTable4 TABLE ( RecID bigint  ,DataValue nvarchar(100))

                  DECLARE  @SqlQuery4 NVARCHAR(300)
                  SET @SqlQuery4='Select RecId, ['+@Day+'] from tblMonthData where PresentMonth='''+@month+''' and  PresentYear= '+@year
                  
				  print @SqlQuery4

                  insert into @TempTable4
                  execute sp_sqlexec @SqlQuery4
				  
				  select * from @TempTable4;

                  --select * from @TempTable1;
                  --------------------------------------------------------------------------------------------------
                  DECLARE idCursor4 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  RecID,DataValue FROM @TempTable4
                  DECLARE @RecID bigint , @DataValue nvarchar(100)
                  OPEN idCursor4 FETCH NEXT FROM idCursor4 INTO @RecID,@DataValue
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  --print 'RecID : '+  cast(@RecID as nvarchar(20)) + ' && DataValue : ' + @DataValue
                  declare @SqlQuery5 nvarchar(200)

				  DECLARE @TEMP VARCHAR(20)=LTRIM(RTRIM(@DataValue));

                  if(@TEMP != '0' and @TEMP != 'P' and @TEMP != 'A' and @TEMP != 'PH' and @TEMP != 'C' and @TEMP != 'WO' and @TEMP != 'NA')        
                  begin 
                       if((cast(@TEMP as float) between 0.1 and 1) )
                       begin 
                       print 'No Need To Change'
                       end
                  end
                  else if(@DayOfWeek1 = 'C' or @DayOfWeek1 = 'PH' )
                  begin
                       set @SqlQuery5='update tblMonthData set ['+@Day+']='''+@DayOfWeek1+''' where PresentMonth='''+@month+''' and  PresentYear= '+@year+' and RecId = '+ cast(@RecID as nvarchar(20))
                       --print 'Change For C and PH'
                       --print @SqlQuery
                       execute sp_sqlexec @SqlQuery5
                  end
                  else 
                  begin
                       set @SqlQuery5='update tblMonthData set ['+@Day+']=''WO'' where PresentMonth='''+@month+''' and  PresentYear= '+@year+' and RecId = '+ cast(@RecID as nvarchar(20)) 
                       --print 'Change For WO'
                            --print @SqlQuery
                       execute sp_sqlexec @SqlQuery5
                  end

                  FETCH NEXT FROM idCursor4 INTO @RecID,@DataValue
                  END
                  CLOSE idCursor4
                  DEALLOCATE idCursor4
                  ------------------------------------------------------------------------------------------------
                  delete from @TempTable4

   
     
	 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @TempTable1 TABLE (EmployeeID nvarchar(100), HolidayStartDate date,HolidayEndDate date)

     Insert into @TempTable1
     --select EmployeeID,HolidayStartDate,HolidayEndDate from tblEmpHoliday where EmployeeID !='000000'
	  --- *********************************************
	 --- CHANGES FOR THE OPTIMIZATION OF QUERY
	 --- *********************************************
	 select EmployeeID,HolidayStartDate,HolidayEndDate from tblEmpHoliday where EmployeeID !='000000' AND DATENAME(YYYY,HolidayEndDate)>=DATENAME(YYYY,GETDATE())
     --select * from @TempTable1

     DECLARE idCursor1 CURSOR                     --iterates over IDs present in the data set
    LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
    FOR SELECT  EmployeeID,HolidayStartDate,HolidayEndDate FROM @TempTable1
     DECLARE @EmployeeID nvarchar(100) ,@HolidayStartDate     date ,@HolidayEndDate date 
     OPEN idCursor1 FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
     WHILE @@FETCH_STATUS=0
         BEGIN

				declare @NumOfDays int
				 set @NumOfDays = (SELECT DATEDIFF(DD, @HolidayStartDate, @HolidayEndDate) AS DateDiff)
				 set @NumOfDays= @NumOfDays+1
				 --print @NumOfDays	

                  declare @count1    int
                  set @count1=0
                  while(@count1 < @NumOfDays)
                  begin
                            declare @month1 nvarchar(10),@year1 nvarchar(10),@Day1 nvarchar(10)
                            set @month1=(select DATENAME(MM,@HolidayStartDate))
                            set @year1=(select DATENAME(YYYY,@HolidayStartDate))
                            set @Day1=(select DATENAME(DD,@HolidayStartDate))

                  DECLARE @TempTable5 TABLE ( RecID bigint  ,DataValue nvarchar(100))

                  DECLARE  @SqlQuery6 NVARCHAR(300)
                  SET @SqlQuery6='select RecId, ['+@Day1+'] from tblMonthData  where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and EmployeeID ='+@EmployeeID
                  --print @SqlQuery6
                  insert into @TempTable5
                  execute sp_sqlexec @SqlQuery6
                  --------------------------------------------------------------------------------------------------
                  DECLARE idCursor5 CURSOR                     --iterates over IDs present in the data set
                  LOCAL FORWARD_ONLY FAST_FORWARD                --optimising for speed and memory
                  FOR SELECT  RecID,DataValue FROM @TempTable5
                  DECLARE @RecID1 bigint , @DataValue1 nvarchar(100)
                  OPEN idCursor5 FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  WHILE @@FETCH_STATUS=0
                  BEGIN
                  --print 'RecID : '+  cast(@RecID1 as nvarchar(20)) + ' && DataValue : ' + @DataValue1
                  
                  if(LTRIM(RTRIM(@DataValue1)) != 'A' and LTRIM(RTRIM(@DataValue1)) != 'P' and LTRIM(RTRIM(@DataValue1)) != '0')        
                  begin 
                       if((cast(LTRIM(RTRIM(@DataValue1)) as float) between 0.1 and 1) )
                       begin 
                       print 'No Need To Change 1'
                       end
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'A')
                  begin
                       declare @SqlQuery1 nvarchar(200)
                       --print 'Step 1'
                       set @SqlQuery1='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       --print @SqlQuery1
                       execute sp_sqlexec @SqlQuery1
                  end
                  else if(LTRIM(RTRIM(@DataValue1)) = 'P' or LTRIM(RTRIM(@DataValue1)) = '0')
                  begin
                       declare @SqlQuery7 nvarchar(200)
                       --print 'Step 2'
                       set @SqlQuery7='update tblMonthData set ['+@Day1+']=''A'' where PresentMonth='''+@month1+''' and  PresentYear= '+@year1+' and ['+@Day1+'] !=''WO''' +' and ['+@Day1+'] !=''C'''+' and ['+@Day1+'] !=''PH''' +' and RecId ='+cast(@RecID1 as nvarchar(20)) 
                       --print @SqlQuery7
                       execute sp_sqlexec @SqlQuery7
                  end

                  FETCH NEXT FROM idCursor5 INTO @RecID1,@DataValue1
                  END
                  CLOSE idCursor5
                  DEALLOCATE idCursor5
                  ------------------------------------------------------------------------------------------------
                  set @HolidayStartDate=(select DATEADD(day,1, @HolidayStartDate))
                  set @count1=@count1+1
                  delete from @TempTable5
                  end
                  
              FETCH NEXT FROM idCursor1 INTO @EmployeeID,@HolidayStartDate,@HolidayEndDate
         END
     CLOSE idCursor1
     DEALLOCATE idCursor1   
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
              DECLARE @TempTable2 TABLE
              (    
                  [MonthName]        varchar(20),
                  [LastDayOfMonth] VARCHAR(10),
                  [MonthYear] VARCHAR(10)
                  )

              declare @start DATE = (Select min(ProjectStartDate) from tblProject)
              declare @end DATE = (Select max(ProjectEndDate) from tblProject)

              ;with months (date)
              AS
              (
                  SELECT @start
                  UNION ALL
                  SELECT DATEADD(month, 1, date)
                  from months
                  where DATEADD(month, 1, date) <= @end
              )
              insert into @TempTable2
              select     [MonthName]    = DATENAME(mm, date),
                          [LastDayOfMonth]  = DATEPART(dd, EOMONTH(date)),
                          [MonthYear]    = DATEPART(yy, date)
              from months

              --select * from @TempTable2;

              DECLARE idCursor2 CURSOR                     --iterates over IDs present in the data set
              LOCAL FORWARD_ONLY FAST_FORWARD               --optimising for speed and memory
              FOR SELECT  [MonthName],[LastDayOfMonth],[MonthYear] FROM @TempTable2
              DECLARE @MonthName nvarchar(100) ,@LastDayOfMonth nvarchar(100),@MonthYear nvarchar(100)
              OPEN idCursor2 FETCH NEXT FROM idCursor2 INTO @MonthName,@LastDayOfMonth,@MonthYear
              WHILE @@FETCH_STATUS=0
                  BEGIN
                            declare @count int
                            set @count=@LastDayOfMonth+1
                            while(@count <= 31)
                            begin
                                     --print @count
                                     declare @SqlQuery2 nvarchar(200)
                                     set @SqlQuery2='update tblMonthData set ['+cast(@count as nvarchar(10))+']=''NA'' where PresentMonth='''+@MonthName+''' and  PresentYear= '+@MonthYear
                                     --print @SqlQuery2
                                     execute sp_sqlexec @SqlQuery2
                                     set @count=@count+1
                            end
                  
                       FETCH NEXT FROM idCursor2 INTO @MonthName,@LastDayOfMonth,@MonthYear
                  END
              CLOSE idCursor2
              DEALLOCATE idCursor2
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     COMMIT TRANSACTION
     END TRY

     BEGIN CATCH
          DECLARE @ErrorSeverity INT
          DECLARE @ErrorState INT
          DECLARE @ErrorMessage NVARCHAR(4000)

          -- Get error text
          SET @ErrorSeverity = ERROR_SEVERITY()
          SET @ErrorState = ERROR_STATE()
         SET @ErrorMessage = dbo.formatErrorLine(OBJECT_NAME(@@PROCID), ERROR_LINE (), ERROR_MESSAGE())

         IF (XACT_STATE() = -1)
         BEGIN
           ROLLBACK TRANSACTION;
          END

          IF (XACT_STATE() = 1)
          BEGIN
           COMMIT TRANSACTION;
          END

         RAISERROR(@ErrorMessage,@ErrorSeverity, @ErrorState) --WITH LOG

     END CATCH














GO
/****** Object:  UserDefinedFunction [dbo].[[Days_To_Table]]]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[[Days_To_Table]]] ( @minDate_Str NVARCHAR(30), @maxDate_Str NVARCHAR(30))

RETURNS  @Result TABLE(DateofMonth NVARCHAR(30) NOT NULL, DaysofMonth NVARCHAR(30) NOT NULL)

AS

begin

    DECLARE @minDate DATETIME, @maxDate DATETIME
    SET @minDate = CONVERT(Datetime, @minDate_Str,103)
    SET @maxDate = CONVERT(Datetime, @maxDate_Str,103)


    INSERT INTO @Result(DateofMonth, DaysofMonth )
    SELECT CONVERT(NVARCHAR(10),@minDate,103), CONVERT(NVARCHAR(30),DATENAME(dw,@minDate))



    WHILE @maxDate > @minDate
    BEGIN
        SET @minDate = (SELECT DATEADD(dd,1,@minDate))
        INSERT INTO @Result(DateofMonth, DaysofMonth )
        SELECT CONVERT(NVARCHAR(10),@minDate,103), CONVERT(NVARCHAR(30),DATENAME(dw,@minDate))
    END


    return

end  


GO
/****** Object:  UserDefinedFunction [dbo].[DateRange_To_Table]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DateRange_To_Table] ( @YEAR VARCHAR(30))

RETURNS @Result TABLE(DateString NVARCHAR(30) NOT NULL, DateNameString NVARCHAR(30) NOT NULL)


AS



begin

DECLARE @minDate_Str VARCHAR(50)='01-01-'+@year
DECLARE @maxDate_Str VARCHAR(50)='31-12-'+@year

DECLARE @minDate DATETIME, @maxDate DATETIME
SET @minDate = CONVERT(Datetime, @minDate_Str,103)
SET @maxDate = CONVERT(Datetime, @maxDate_Str,103)


INSERT INTO @Result(DateString, DateNameString )
SELECT CONVERT(NVARCHAR(10),@minDate,103), CONVERT(NVARCHAR(30),DATENAME(dw,@minDate))



WHILE @maxDate > @minDate
BEGIN
SET @minDate = (SELECT DATEADD(dd,1,@minDate))
INSERT INTO @Result(DateString, DateNameString )
SELECT CONVERT(NVARCHAR(10),@minDate,103), CONVERT(NVARCHAR(30),DATENAME(dw,@minDate)) WHERE CONVERT(NVARCHAR(30),DATENAME(dw,@minDate))='Sunday' OR CONVERT(NVARCHAR(30),DATENAME(dw,@minDate))='Saturday'
END

RETURN

END


GO
/****** Object:  UserDefinedFunction [dbo].[fct_IsDateWeekend]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fct_IsDateWeekend] ( @date DATETIME )
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN DATEPART(DW, @date + @@DATEFIRST - 1) > 5  THEN 1 ELSE 0 END;
END;


GO
/****** Object:  UserDefinedFunction [dbo].[formatErrorLine]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


 
 CREATE FUNCTION [dbo].[formatErrorLine] 
(
    @ErrorProcedure NVARCHAR(255),
	@ErrorLine INT,
    @ErrorMessage NVARCHAR(4000)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

               -- Concatinate errorline and error function if existing
               IF @ErrorLine IS NOT NULL AND @ErrorProcedure IS NOT NULL
               BEGIN
                          return 'Procedure/Function: ' + @ErrorProcedure 
                          + ', Line (use "sp_helptext ' + @ErrorProcedure + '"): ' + CAST(@ErrorLine AS NVARCHAR(10)) + ', Message: ' + @ErrorMessage
               END


	RETURN @ErrorMessage
END








GO
/****** Object:  Table [dbo].[tblAssignedProject]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAssignedProject](
	[RecId] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](max) NULL,
	[EmployeeName] [varchar](max) NULL,
	[ProjectCode] [varchar](max) NULL,
	[ProjectName] [varchar](max) NULL,
	[ProjectAssignedDate] [varchar](max) NULL,
	[ProjectEndDate] [varchar](max) NULL,
	[OperatorName] [varchar](max) NULL,
	[LastEditTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblEmpHoliday]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmpHoliday](
	[RecId] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](max) NULL,
	[EmployeeName] [varchar](max) NULL,
	[Department] [varchar](max) NULL,
	[HolidayStartDate] [date] NULL,
	[HolidayEndDate] [date] NULL,
	[Reason] [varchar](max) NULL,
	[NumberOfDays] [int] NULL,
	[OperatorName] [varchar](max) NULL,
	[LastEditTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblEmployee]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmployee](
	[RecId] [bigint] NULL,
	[EmployeeID] [varchar](max) NULL,
	[EmployeeName] [varchar](max) NULL,
	[PositionTitle] [varchar](max) NULL,
	[Department] [varchar](max) NULL,
	[DirectSupervisor] [varchar](max) NULL,
	[CostCentre] [varchar](max) NULL,
	[OperatorName] [varchar](max) NULL,
	[LastEditTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblHolidayCalander]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHolidayCalander](
	[DateOfHoliday] [date] NULL,
	[DayOfWeek1] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMonthData]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMonthData](
	[RecId] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[ProjectID] [bigint] NULL,
	[PresentMonth] [nvarchar](50) NULL,
	[PresentYear] [nvarchar](50) NULL,
	[Task] [nvarchar](150) NULL,
	[ManDays] [int] NULL,
	[1] [nchar](10) NULL,
	[2] [nchar](10) NULL,
	[3] [nchar](10) NULL,
	[4] [nchar](10) NULL,
	[5] [nchar](10) NULL,
	[6] [nchar](10) NULL,
	[7] [nchar](10) NULL,
	[8] [nchar](10) NULL,
	[9] [nchar](10) NULL,
	[10] [nchar](10) NULL,
	[11] [nchar](10) NULL,
	[12] [nchar](10) NULL,
	[13] [nchar](10) NULL,
	[14] [nchar](10) NULL,
	[15] [nchar](10) NULL,
	[16] [nchar](10) NULL,
	[17] [nchar](10) NULL,
	[18] [nchar](10) NULL,
	[19] [nchar](10) NULL,
	[20] [nchar](10) NULL,
	[21] [nchar](10) NULL,
	[22] [nchar](10) NULL,
	[23] [nchar](10) NULL,
	[24] [nchar](10) NULL,
	[25] [nchar](10) NULL,
	[26] [nchar](10) NULL,
	[27] [nchar](10) NULL,
	[28] [nchar](10) NULL,
	[29] [nchar](10) NULL,
	[30] [nchar](10) NULL,
	[31] [nchar](10) NULL,
	[Remarks] [nvarchar](max) NULL,
 CONSTRAINT [PK_tblMonthData] PRIMARY KEY CLUSTERED 
(
	[RecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProject]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblProject](
	[RecId] [bigint] IDENTITY(1,1) NOT NULL,
	[ProjectID] [bigint] NULL,
	[ProjectCode] [varchar](max) NULL,
	[ProjectType] [varchar](max) NULL,
	[ProjectName] [varchar](max) NULL,
	[ProjectStartDate] [date] NULL,
	[ProjectEndDate] [date] NULL,
	[OldProjectEndDate] [date] NULL,
	[ProjectCategory] [varchar](max) NULL,
	[ProjectSegment] [varchar](max) NULL,
	[ProjectStage] [varchar](max) NULL,
	[ProjectStatus] [varchar](max) NULL,
	[Reporting] [varchar](max) NULL,
	[ProjectManager] [varchar](max) NULL,
	[OperatorName] [varchar](max) NULL,
	[LastEditTime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTask]    Script Date: 11-04-2023 16:21:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTask](
	[RecID] [int] IDENTITY(1,1) NOT NULL,
	[EmpID] [nvarchar](100) NULL,
	[ProjectID] [nvarchar](100) NULL,
	[ProjectCode] [nvarchar](100) NULL,
	[PMonth] [nvarchar](100) NULL,
	[PYear] [nvarchar](100) NULL,
	[Task] [nvarchar](150) NULL,
 CONSTRAINT [PK_tblTask] PRIMARY KEY CLUSTERED 
(
	[RecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[tblEmpHoliday] ON 

GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (2, N'000000', N'000000', N'000000', CAST(N'2022-01-26' AS Date), CAST(N'2022-01-26' AS Date), N'REPUBLIC DAY ', 1, NULL, CAST(N'2022-07-05 10:29:49.000' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (3, N'000000', N'000000', N'000000', CAST(N'2022-03-01' AS Date), CAST(N'2022-03-01' AS Date), N'MAHA SHIVRATRI', 1, NULL, CAST(N'2022-07-05 10:31:09.873' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (4, N'000000', N'000000', N'000000', CAST(N'2022-05-03' AS Date), CAST(N'2022-05-03' AS Date), N'EID UL-FITR', 1, NULL, CAST(N'2022-07-05 10:39:19.070' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (5, N'000000', N'000000', N'000000', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-11' AS Date), N'RAKSHA BANDHAN', 1, NULL, CAST(N'2022-07-05 10:41:07.840' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (6, N'000000', N'000000', N'000000', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-15' AS Date), N'INDEPENDENCE DAY', 1, NULL, CAST(N'2022-07-05 10:53:22.770' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (7, N'000000', N'000000', N'000000', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-19' AS Date), N'JANMASHTAMI', 1, NULL, CAST(N'2022-07-05 10:54:13.960' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (8, N'000000', N'000000', N'000000', CAST(N'2022-09-17' AS Date), CAST(N'2022-09-17' AS Date), N'VISHWAKARMA POOJA', 0, NULL, CAST(N'2022-07-05 10:55:25.240' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (9, N'000000', N'000000', N'000000', CAST(N'2022-10-02' AS Date), CAST(N'2022-10-02' AS Date), N'MAHATMA GANDHI''S BIRTHDAY', 0, NULL, CAST(N'2022-07-05 10:57:07.403' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (10, N'000000', N'000000', N'000000', CAST(N'2022-10-05' AS Date), CAST(N'2022-10-05' AS Date), N'DUSSEHRA', 1, NULL, CAST(N'2022-07-05 10:58:32.573' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (11, N'000000', N'000000', N'000000', CAST(N'2022-10-24' AS Date), CAST(N'2022-10-24' AS Date), N'DIWALI', 1, NULL, CAST(N'2022-07-05 10:59:08.267' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (12, N'000000', N'000000', N'000000', CAST(N'2022-10-25' AS Date), CAST(N'2022-10-25' AS Date), N'GOVERDHAN POOJA', 1, NULL, CAST(N'2022-07-05 10:59:42.673' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (13, N'000000', N'000000', N'000000', CAST(N'2022-11-08' AS Date), CAST(N'2022-11-08' AS Date), N'GURU NANAK BIRTHDAY', 1, NULL, CAST(N'2022-07-05 11:00:31.290' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (14, N'000000', N'000000', N'000000', CAST(N'2022-12-25' AS Date), CAST(N'2022-12-25' AS Date), N'CHRISTMAS DAY', 0, NULL, CAST(N'2022-07-05 11:01:17.323' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (15, N'000000', N'000000', N'000000', CAST(N'2022-01-01' AS Date), CAST(N'2022-01-01' AS Date), N'NEW YEAR ', 0, NULL, CAST(N'2022-07-05 10:27:07.513' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (16, N'000000', N'000000', N'000000', CAST(N'2022-03-18' AS Date), CAST(N'2022-03-18' AS Date), N'HOLI', 1, NULL, CAST(N'2022-07-05 10:33:50.843' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (17, N'000000', N'000000', N'000000', CAST(N'2022-04-15' AS Date), CAST(N'2022-04-15' AS Date), N'GOOD FRIDAY', 1, NULL, CAST(N'2022-07-05 10:34:25.450' AS DateTime))
GO
INSERT [dbo].[tblEmpHoliday] ([RecId], [EmployeeID], [EmployeeName], [Department], [HolidayStartDate], [HolidayEndDate], [Reason], [NumberOfDays], [OperatorName], [LastEditTime]) VALUES (18, N'000000', N'000000', N'000000', CAST(N'2022-05-01' AS Date), CAST(N'2022-05-01' AS Date), N'MAY DAY', 0, NULL, CAST(N'2022-07-05 10:35:08.640' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tblEmpHoliday] OFF
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (1, N'705192', N'Sachin Raja', N'Chief - Operations Engineering', N'EN', N'Vyas, Nitin (981721)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (2, N'701880', N'Manmeet Singh Virdi', N'Head - Automation', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (3, N'708078', N'Arshad Raza', N'Head - ED (OLBC)', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (4, N'901130', N'Ajay Sehdev', N'Sr Manager', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (5, N'901132', N'Ashutosh Srivastava', N'Head - ED (Cement)', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (6, N'981900', N'Sairaj Herekar', N'Sr Manager', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (7, N'705088', N'Rajni Mehra', N'Asst Manager', N'EN', N'Raja, Sachin (705192)', N'4618 - Management of Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (8, N'982434', N'Mohit Taneja', N'Manager', N'EN-AT - Automation', N'Raja, Sachin (705192)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (9, N'700023', N'Pankaj Kumar Sharma', N'Sr Manager', N'EN-CE - Engineering (Cement)', N'Raja, Sachin (705192)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (10, N'711305', N'Himanshu Joshi', N'Senior Manager', N'EN-CI - Civil Structure Engineering', N'Raja, Sachin (705192)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (11, N'982294', N'Keshav Dubal', N'Sr Manager', N'IT - IT', N'Raja, Sachin (705192)', N'4603 - IT', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (12, N'703809', N'Ravinder Kumar', N'Dy Manager', N'IT - IT', N'Dubal, Keshav (982294)', N'4603 - IT', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (13, N'710397', N'Amit Kumar', N'Dy Manager', N'IT - IT', N'Dubal, Keshav (982294)', N'4603 - IT', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (14, N'709756', N'Karan Mehra', N'Junior Associate', N'IT - IT', N'Kumar, Amit (710397)', N'4603 - IT', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (15, N'709669', N'Rohan Mishra', N'Junior Associate', N'IT - IT', N'Kumar, Ravinder (703809)', N'4603 - IT', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (16, N'700026', N'Dharmender Rohilla', N'Dy Manager', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (17, N'700031', N'Sandeep Sharma', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (18, N'707212', N'Manmohan Yadav', N'Associate', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (19, N'708984', N'Pushpendra Pal Singh', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (20, N'708973', N'Nimish Singh', N'Associate', N'EN-CE - Engineering (Cement)', N'Sehdev, Ajay (901130)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (21, N'709295', N'Mohan Yadav', N'Sr Associate', N'EN-CE - Engineering (Cement)', N'Sehdev, Ajay (901130)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (22, N'700044', N'Rakesh Singh', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Sharma, Pankaj Kumar (700023)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (23, N'701136', N'Hari Raj', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Sharma, Pankaj Kumar (700023)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (24, N'706779', N'Rajesh Kumar', N'Associate', N'EN-CE - Engineering (Cement)', N'Sharma, Pankaj Kumar (700023)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (25, N'707805', N'Sudhanshu Joshi', N'Associate', N'EN-CE - Engineering (Cement)', N'Sharma, Pankaj Kumar (700023)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (26, N'708182', N'Mayank Srivastava', N'Associate', N'EN-CE - Engineering (Cement)', N'Sharma, Pankaj Kumar (700023)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (27, N'700022', N'Arvind Kumar', N'Sr Manager', N'EN-CE - Engineering (Cement)', N'Srivastava, Ashutosh (901132)', N'4611 - ED - PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (28, N'711376', N'Pradeep Kumar', N'DET', N'EN-CI - Civil Structure Engineering', N'Badar, Feraz (709743)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (29, N'707959', N'Soumen Metya', N'Sr Associate', N'EN-CI - Civil Structure Engineering', N'Joshi, Himanshu (711305)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (30, N'709743', N'Feraz Badar', N'Asst Manager', N'EN-CI - Civil Structure Engineering', N'Joshi, Himanshu (711305)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (31, N'709888', N'Vaishali Sharma', N'Asst Manager', N'EN-CI - Civil Structure Engineering', N'Joshi, Himanshu (711305)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (32, N'708079', N'Dandu Alekhya', N'Associate', N'EN-CI - Civil Structure Engineering', N'Metya, Soumen (707959)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (33, N'708883', N'Surajit kumar jana', N'Sr Associate', N'EN-CI - Civil Structure Engineering', N'Sharma, Vaishali (709888)', N'4612 - Civil Structural Engineering', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (34, N'700040', N'Ajay Kamboj', N'Sr Manager', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4613 - ED-CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (35, N'700262', N'Ravi Kumar Singh', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Kumar, Arvind (700022)', N'4613 - ED-CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (36, N'700028', N'Kiranpal Tanwar', N'Manager', N'EN-CE - Engineering (Cement)', N'Srivastava, Ashutosh (901132)', N'4614 - ED-CLP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (37, N'700234', N'Kusal Kumar', N'Asst Manager', N'EN-CE - Engineering (Cement)', N'Tanwar, Kiranpal (700028)', N'4614 - ED-CLP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (38, N'708183', N'Tushar Dewanjee', N'Associate', N'EN-CE - Engineering (Cement)', N'Tanwar, Kiranpal (700028)', N'4614 - ED-CLP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (39, N'709317', N'Kishan Sharma', N'Associate', N'EN-CE - Engineering (Cement)', N'Tanwar, Kiranpal (700028)', N'4614 - ED-CLP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (40, N'700039', N'Rajeev Lochan Vashishth', N'Dy Manager', N'EN-ST - Standardisation', N'Sehdev, Ajay (901130)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (41, N'705001', N'Gurudev Singh', N'Sr Associate', N'EN-ST - Standardisation', N'Sharma, Mayank (700042)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (42, N'705073', N'Vanita Devi', N'Sr Associate', N'EN-ST - Standardisation', N'Sharma, Mayank (700042)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (43, N'709618', N'Jagrit Bhatia', N'GET', N'EN-ST - Standardisation', N'Sharma, Mayank (700042)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (44, N'709619', N'Himanshu Tripathi', N'GET', N'EN-ST - Standardisation', N'Sharma, Mayank (700042)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (45, N'901134', N'Deepak Ahlawat', N'Asst Manager', N'EN-ST - Standardisation', N'Sharma, Mayank (700042)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (46, N'700042', N'Mayank Sharma', N'Dy Manager', N'EN-ST - Standardisation', N'Srivastava, Ashutosh (901132)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (47, N'700025', N'Arvind Kumar', N'Associate', N'EN-ST - Standardisation', N'Vashishth, Rajeev Lochan (700039)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (48, N'700036', N'Sumit Singh', N'Sr Associate', N'EN-ST - Standardisation', N'Vashishth, Rajeev Lochan (700039)', N'4615 - Standardzation', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (49, N'709686', N'Aman Singh Yadav', N'Asst Manager', N'EN-AI - Engineering (Airports & Logistics)', N'Herekar, Sairaj (981900)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (50, N'982337', N'Supriya Gholap', N'Asst Manager', N'EN-AI - Engineering (Airports & Logistics)', N'Herekar, Sairaj (981900)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (51, N'707293', N'Manjeet Singh', N'Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Mishra, Shubha (706930)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (52, N'709471', N'Nikhil Berwal', N'GET', N'EN-AI - Engineering (Airports & Logistics)', N'Mishra, Shubha (706930)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (53, N'707906', N'Sita Ram', N'External Consultant', N'EN-AI - Engineering (Airports & Logistics)', N'Murthy, Saikumar (982334)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (54, N'707508', N'Shubham Somani', N'Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Yadav, Aman Singh (709686)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (55, N'707627', N'Shubham R Khurapi', N'Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Yadav, Aman Singh (709686)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (56, N'708187', N'Sunil Raghuveer', N'Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Yadav, Aman Singh (709686)', N'4616 - ED-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (57, N'982335', N'Ajay Patil', N'Sr Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Gholap, Supriya (982337)', N'4617 - ED-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (58, N'706930', N'Shubha Mishra', N'Dy Manager', N'EN-AI - Engineering (Airports & Logistics)', N'Herekar, Sairaj (981900)', N'4617 - ED-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (59, N'711324', N'Deepak Sharma', N'Sr Associate', N'EN-AI - Engineering (Airports & Logistics)', N'Herekar, Sairaj (981900)', N'4617 - ED-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (60, N'707060', N'Ajay Singh Bhandari', N'Associate', N'EN-AT - Automation', N'Chandra, Satish (704510)', N'4619 - AT - CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (61, N'708039', N'Mayank Sharma', N'Associate', N'EN-AT - Automation', N'Pandey, Neeraj (706653)', N'4619 - AT - CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (62, N'709582', N'Abhishek Shahi', N'GET', N'EN-AT - Automation', N'Pandey, Neeraj (706653)', N'4619 - AT - CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (63, N'706653', N'Neeraj Pandey', N'Dy Manager', N'EN-AT - Automation', N'Raza, Arshad (708078)', N'4619 - AT - CLS', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (64, N'707534', N'Shivam Singh', N'Associate', N'EN-AT - Automation', N'Chaurasiya, Rahul (700932)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (65, N'709519', N'Nayak Ganesh Prasad', N'GET', N'EN-AT - Automation', N'Chaurasiya, Rahul (700932)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (66, N'705892', N'Aninda Maiti', N'Asst. Manager', N'EN-AT - Automation', N'Herekar, Sairaj (981900)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (67, N'709438', N'Sanni Agarwal', N'Sr Associate', N'EN-AT - Automation', N'Kaur, Rajinderpal (706568)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (68, N'709580', N'Ashutosh Kumar Happy', N'GET', N'EN-AT - Automation', N'Maiti, Aninda (705892)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (69, N'708190', N'Ganesh Setti', N'Associate', N'EN-AT - Automation', N'Singh, Kulkaran (705795)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (70, N'708450', N'Pragadeesh S', N'Associate', N'EN-AT - Automation', N'Singh, Kulkaran (705795)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (71, N'709116', N'Arun Raj', N'Sr Associate', N'EN-AT - Automation', N'Singh, Kulkaran (705795)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (72, N'709662', N'Moazzam Alam', N'Sr Associate', N'EN-AT - Automation', N'Singh, Kulkaran (705795)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (73, N'700932', N'Rahul Chaurasiya', N'Sr Manager', N'EN-AT - Automation', N'Virdi, Manmeet Singh (701880)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (74, N'706568', N'Rajinderpal Kaur', N'Asst Manager', N'EN-AT - Automation', N'Virdi, Manmeet Singh (701880)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (75, N'709687', N'Lalit Kumar', N'Asst Manager', N'EN-AT - Automation', N'Virdi, Manmeet Singh (701880)', N'4682 - AT-AP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (76, N'707790', N'Mohd Nasir', N'Associate  -  Automation', N'EN-AT - Automation', N'Chandra, Satish (704510)', N'4683 - AT-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (77, N'706908', N'Naveen Kumar', N'Sr Associate', N'EN-AT - Automation', N'Maiti, Aninda (705892)', N'4683 - AT-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (78, N'705795', N'Kulkaran Singh', N'Dy Manager', N'EN-AT - Automation', N'Virdi, Manmeet Singh (701880)', N'4683 - AT-LOG', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (79, N'706781', N'Sachin Kapil', N'Associate', N'EN-AT - Automation', N'Joshi, Mamta (702140)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (80, N'708095', N'K.Rohith Kanth', N'Associate', N'EN-AT - Automation', N'Joshi, Mamta (702140)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (81, N'704510', N'Satish Chandra', N'Asst Manager', N'EN-AT - Automation', N'Sehdev, Ajay (901130)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (82, N'702140', N'Mamta Joshi', N'Dy Manager', N'EN-AT - Automation', N'Srivastava, Ashutosh (901132)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (83, N'710112', N'Bhaskar Jyoti Deka', N'Asst Manager', N'EN-AT - Automation', N'Taneja, Mohit (982434)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (84, N'710243', N'Vibhav Mishra', N'Sr Associate', N'EN-AT - Automation', N'Taneja, Mohit (982434)', N'4684 - AT-PP', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (85, N'711340', N'Nazir Ali Shah', N'Sr Manager', N'EN-OL-Engineering-OLBC', N'Das, Abhijit (710450)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (86, N'703314', N'Saurabh Samadhiya', N'Asst Manager', N'EN-OL-Engineering-OLBC', N'Jajoria, Yogender (700041)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (87, N'706290', N'Rishab Kamboj', N'Associate', N'EN-OL-Engineering-OLBC', N'Jajoria, Yogender (700041)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (88, N'709316', N'Nawes Qamar', N'Associate', N'EN-OL-Engineering-OLBC', N'Kumar, Dharmender (708024)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (89, N'709601', N'Mukesh Kumar', N'Asst Manager', N'EN-OL-Engineering-OLBC', N'Kumar, Dharmender (708024)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (90, N'700041', N'Yogender Jajoria', N'Dy Manager', N'EN-OL-Engineering-OLBC', N'Raza, Arshad (708078)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (91, N'708024', N'Dharmender Kumar', N'Dy Manager', N'EN-OL-Engineering-OLBC', N'Raza, Arshad (708078)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (92, N'709551', N'VIJAY KUMAR', N'Sr Associate', N'EN-OL-Engineering-OLBC', N'Raza, Arshad (708078)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblEmployee] ([RecId], [EmployeeID], [EmployeeName], [PositionTitle], [Department], [DirectSupervisor], [CostCentre], [OperatorName], [LastEditTime]) VALUES (93, N'710247', N'Shantanu Kumar', N'Dy Manager', N'EN-OL-Engineering-OLBC', N'Raza, Arshad (708078)', N'4685 - ED-CLS (OLBC)', N'Admin', CAST(N'2022-12-06 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-10' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-11' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-17' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-18' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-24' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-25' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2022-12-31' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-01' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-07' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-08' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-14' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-15' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-21' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-22' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-28' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-01-29' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-04' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-05' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-11' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-12' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-18' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-19' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-25' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-02-26' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-04' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-05' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-11' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-12' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-18' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-19' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-25' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-03-26' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-01' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-02' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-08' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-09' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-15' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-16' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-22' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-23' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-29' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-04-30' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-06' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-07' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-13' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-14' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-20' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-21' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-27' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-05-28' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-03' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-04' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-10' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-11' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-17' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-18' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-24' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-06-25' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-01' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-02' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-08' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-09' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-15' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-16' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-22' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-23' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-29' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-07-30' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-05' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-06' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-12' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-13' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-19' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-20' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-26' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-08-27' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-02' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-03' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-09' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-10' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-16' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-17' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-23' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-24' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-09-30' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-01' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-07' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-08' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-14' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-15' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-21' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-22' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-28' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-10-29' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-04' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-05' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-11' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-12' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-18' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-19' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-25' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-11-26' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-02' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-03' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-09' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-10' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-16' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-17' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-23' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-24' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-30' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2023-12-31' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-06' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-07' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-13' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-14' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-20' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-21' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-27' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-01-28' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-03' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-04' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-10' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-11' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-17' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-18' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-24' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-02-25' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-02' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-03' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-09' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-10' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-16' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-17' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-23' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-24' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-30' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-03-31' AS Date), N'Sunday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-04-06' AS Date), N'Saturday')
GO
INSERT [dbo].[tblHolidayCalander] ([DateOfHoliday], [DayOfWeek1]) VALUES (CAST(N'2024-04-07' AS Date), N'Sunday')
GO
SET IDENTITY_INSERT [dbo].[tblMonthData] ON 

GO
INSERT [dbo].[tblMonthData] ([RecId], [EmployeeID], [ProjectID], [PresentMonth], [PresentYear], [Task], [ManDays], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [Remarks]) VALUES (1, N'700039', 156, N'December', N'2022', N'Documentation', NULL, N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'          ', N'1         ', N'WO        ', N'WO        ', N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'WO        ', N'WO        ', N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'WO        ', N'WO        ', N'1         ', N'1         ', N'1         ', N'1         ', N'1         ', N'WO        ', N'')
GO
INSERT [dbo].[tblMonthData] ([RecId], [EmployeeID], [ProjectID], [PresentMonth], [PresentYear], [Task], [ManDays], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [Remarks]) VALUES (4, N'703809', 38, N'January', N'2023', N'testing for new', NULL, N'WO        ', N'P         ', N'P         ', N'P         ', N'P         ', N'P         ', N'WO        ', N'WO        ', N'P         ', N'P         ', N'P         ', N'P         ', N'P         ', N'WO        ', N'WO        ', N'P         ', N'P         ', N'P         ', N'P         ', N'P         ', N'WO        ', N'WO        ', N'P         ', N'P         ', N'P         ', N'P         ', N'P         ', N'WO        ', N'WO        ', N'P         ', N'P         ', NULL)
GO
SET IDENTITY_INSERT [dbo].[tblMonthData] OFF
GO
SET IDENTITY_INSERT [dbo].[tblProject] ON 

GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (1, 1, N'617-450059', N'Awarded', N'NCC Limited-Agartala - IXA', CAST(N'2017-12-27' AS Date), CAST(N'2022-01-12' AS Date), NULL, N'C', N'Airports ', N'Design', N'Closed', N'No', N'Manjeet Dabas', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (2, 2, N'618-450068', N'Awarded', N'Bharat Heavy Electrical Ltd', CAST(N'2018-08-31' AS Date), CAST(N'2022-04-30' AS Date), NULL, N'B', N'CLS', N'Installation', N'Open', N'Yes', N'Jinendra Jain', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (3, 3, N'618-450072', N'Awarded', N'Bharat Heavy Electrical Ltd', CAST(N'2018-08-31' AS Date), CAST(N'2022-04-30' AS Date), NULL, N'B', N'CLS', N'Installation', N'Open', N'Yes', N'Jinendra Jain', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (4, 4, N'619-450001', N'Awarded', N'J.K.Cement Ltd', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (5, 5, N'619-450002', N'Awarded', N'RCCPL Private Limited', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (6, 6, N'619-450003', N'Awarded', N'Narayani cement Udyog (P) Ltd', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Sachin Sharma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (7, 7, N'619-450008', N'Awarded', N'Gebr. Pfeiffer (India) Private Ltd', CAST(N'2019-02-06' AS Date), CAST(N'2019-09-10' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (8, 8, N'619-450009', N'Awarded', N'Chandigarh International Airport-IXC', NULL, NULL, NULL, N'D', N'Airports ', N'Handover to CS', N'Closed', N'No', N'Manjeet Dabas', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (9, 9, N'619-450010', N'Awarded', N'Bangalore - BLR - Terminal 2', CAST(N'2019-02-02' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'B', N'Airports ', N'Commissioning', N'Open', N'Yes', N'SaiKumar Murthy', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (10, 10, N'619-450014', N'Awarded', N'GMR Hyderabad International', CAST(N'2019-12-07' AS Date), CAST(N'2019-07-23' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (11, 11, N'619-450016', N'Awarded', N'JSW Cement Limited', NULL, NULL, NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Abhishek Chaudhary', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (12, 12, N'619-450017', N'Awarded', N'AMBUJA CEMENTS LIMITED', CAST(N'2019-03-26' AS Date), CAST(N'2019-12-31' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (13, 13, N'619-450018', N'Awarded', N'ThyssenKrupp Industries India Pvt. Ltd.', CAST(N'2019-02-21' AS Date), CAST(N'2019-09-07' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (14, 14, N'619-450025', N'Awarded', N'Ultra Tech', CAST(N'2019-04-05' AS Date), CAST(N'2019-12-04' AS Date), NULL, N'D', N'CLP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (15, 15, N'619-450029', N'Awarded', N'RCCPL Private Ltd', CAST(N'2019-08-05' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'C', N'CLS', N'Handover to CS', N'Closed', N'Yes', N'Jinendra Jain', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (16, 16, N'619-450030', N'Awarded', N'TATA Steel Kalinganagar', CAST(N'2019-08-06' AS Date), CAST(N'2020-06-06' AS Date), NULL, N'C', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (17, 17, N'619-450031', N'Awarded', N'Ambuja Cements Limited', NULL, NULL, NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Abhishek Chaudhary', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (18, 18, N'619-450033', N'Awarded', N'Bangalore - BLR - Terminal 2', CAST(N'2019-02-02' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'B', N'Airports ', N'Commissioning', N'Open', N'Yes', N'SaiKumar Murthy', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (19, 19, N'619-450034', N'Awarded', N'Bangalore - BLR - Terminal 2', CAST(N'2019-02-02' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'B', N'Airports ', N'Commissioning', N'Open', N'Yes', N'SaiKumar Murthy', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (20, 20, N'619-450035', N'Awarded', N'GMR Hyderabad International', CAST(N'2019-06-12' AS Date), CAST(N'2019-08-31' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (21, 21, N'619-450039', N'Awarded', N'GE Power India Limited', CAST(N'2020-09-13' AS Date), CAST(N'2021-07-30' AS Date), NULL, N'C', N'CLS', N'Installation', N'Open', N'Yes', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (22, 22, N'619-450040', N'Awarded', N'Shree Cement Ltd.Maharashtra', CAST(N'2019-09-26' AS Date), CAST(N'2020-01-31' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (23, 23, N'619-450042', N'Awarded', N'J K CEMENT LIMITED', CAST(N'2019-11-04' AS Date), CAST(N'2021-02-04' AS Date), NULL, N'C', N'CLS', N'Handover to CS', N'Closed', N'Yes', N'Jinendra Jain', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (24, 24, N'619-450046', N'Awarded', N'KHD JSW Cement Salem', CAST(N'2019-11-22' AS Date), CAST(N'2020-04-30' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (25, 25, N'619-450047', N'Awarded', N'Dehradun - DED - New Terminal', CAST(N'2019-12-07' AS Date), CAST(N'2020-12-06' AS Date), NULL, N'C', N'Airports ', N'Commissioning', N'Closed', N'No', N'Amit Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (26, 26, N'619-450048', N'Awarded', N'ACC Limited Tikaria Cement Works', CAST(N'2019-12-20' AS Date), CAST(N'2021-06-30' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (27, 27, N'620-450001', N'Awarded', N'Nuvoco Vistas Corporation Limited', CAST(N'2019-12-12' AS Date), CAST(N'2020-07-30' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (28, 28, N'620-450002', N'Awarded', N'SHAYONA CEMENT CORPORATION', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (29, 29, N'620-450003', N'Awarded', N'Hyderabad - HYD - Expansion', CAST(N'2020-01-28' AS Date), CAST(N'2022-02-15' AS Date), NULL, N'B', N'Airports ', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (30, 30, N'620-450004', N'Awarded', N'Haver & Boecker OHG', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (31, 31, N'620-450005', N'Awarded', N'LNV TECHNOLOGY PRIVATE LIMITED', CAST(N'2020-02-10' AS Date), CAST(N'2020-06-30' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (32, 32, N'620-450006', N'Awarded', N'LNV TECHNOLOGY PRIVATE LIMITED - Tikaria', CAST(N'2020-02-10' AS Date), CAST(N'2021-07-31' AS Date), NULL, N'D', N'PP', N'Handover to CS', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (33, 33, N'620-450007', N'Awarded', N'Ultratech Cement Ltd. - Cuttack', CAST(N'2020-03-03' AS Date), CAST(N'2021-05-31' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (34, 34, N'620-450008', N'Awarded', N'UTCL Cuttack', CAST(N'2020-02-27' AS Date), CAST(N'2020-07-26' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (35, 35, N'620-450009', N'Awarded', N'Ultratech Cement Limited', NULL, NULL, NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (36, 36, N'620-450010', N'Awarded', N'Ultratech Cement Limited (UTCL)', NULL, NULL, NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (37, 37, N'620-450011', N'Awarded', N'ACC LIMITED (Ametha)', CAST(N'2020-12-15' AS Date), CAST(N'2021-10-20' AS Date), NULL, N'C', N'PP', N'Installation', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (38, 38, N'620-450012', N'Awarded', N'JSW Cement Ltd', CAST(N'2022-02-16' AS Date), CAST(N'2023-02-08' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (39, 39, N'620-450016', N'Awarded', N'Humboldt Wedag India Pvt. Ltd.', CAST(N'2021-04-27' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Commissioned', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (40, 40, N'620-450017', N'Awarded', N'BHEL-Industrial Systems Group', CAST(N'2020-06-18' AS Date), CAST(N'2022-06-17' AS Date), NULL, N'C', N'CLS', N'On Hold', N'On Hold', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (41, 41, N'620-450018', N'Awarded', N'BHEL-Industrial Systems Group', CAST(N'2020-06-18' AS Date), CAST(N'2022-06-17' AS Date), NULL, N'C', N'CLS', N'On Hold', N'On Hold', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (42, 42, N'620-450021', N'Awarded', N'ULTRATECH CEMENT LTD', CAST(N'2020-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (43, 43, N'620-450022', N'Awarded', N'INSTAKART SERVICES PRIVATE LIMITED', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), CAST(N'2022-12-05' AS Date), N'B', N'Airports ', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-12-05 14:30:09.333' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (44, 44, N'620-450023', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (45, 45, N'620-450024', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (46, 46, N'620-450025', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (47, 47, N'620-450027', N'Awarded', N'FLSMIDTH PRIVATE LIMITED', CAST(N'2020-07-30' AS Date), CAST(N'2020-11-30' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (48, 48, N'620-450028', N'Awarded', N'Ambuja Cements Limited ( Unit : Marwar Mundwa)', NULL, NULL, NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Abhishek Chaudhary', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (49, 49, N'620-450031', N'Awarded', N'Shree Cement Limited', CAST(N'2020-09-07' AS Date), CAST(N'2021-01-06' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (50, 50, N'620-450033', N'Awarded', N'RAS NEW CEMENT UNIT', CAST(N'2020-10-08' AS Date), CAST(N'2021-04-07' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (51, 51, N'620-450035', N'Awarded', N'Dehradun - DED - New Terminal', CAST(N'2019-12-07' AS Date), CAST(N'2020-12-06' AS Date), NULL, N'C', N'Airports ', N'Commissioning', N'Closed', N'No', N'Amit Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (52, 52, N'620-450036', N'Awarded', N'Ambuja Cements Limited ( Unit : Marwar Mundwa)', NULL, NULL, NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Abhishek Chaudhary', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (53, 53, N'620-450037', N'Awarded', N'SHREE RAIPUR CEMENT PLANT', CAST(N'2020-12-03' AS Date), CAST(N'2021-08-01' AS Date), CAST(N'2022-12-05' AS Date), N'D', N'PP', N'Handover to CS', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-12-05 14:30:57.507' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (54, 54, N'620-450038', N'Awarded', N'JSW Cement Ltd', CAST(N'2020-12-16' AS Date), CAST(N'2021-06-21' AS Date), NULL, N'D', N'PP', N'Handover to CS', N'Closed', N'No', N'Gaurav Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (55, 55, N'620-450039', N'Awarded', N'SHREE RENUKA SUGARS LIMITED', CAST(N'2020-12-14' AS Date), CAST(N'2021-06-30' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (56, 56, N'620-450040', N'Awarded', N'ACC LIMITED', CAST(N'2020-12-24' AS Date), CAST(N'2021-06-29' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (57, 57, N'620-450041', N'Awarded', N'JSW Cement Ltd.', CAST(N'2020-12-23' AS Date), CAST(N'2021-07-14' AS Date), NULL, N'D', N'PP', N'Handover to CS', N'Closed', N'No', N'Gaurav Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (58, 58, N'620-450042', N'Awarded', N'ThyssenKrupp Industries India Pvt. Ltd.', CAST(N'2021-01-09' AS Date), CAST(N'2021-09-10' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (59, 59, N'621-450001', N'Awarded', N'RAS NEW CEMENT UNIT', CAST(N'2021-01-13' AS Date), CAST(N'2021-07-13' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (60, 60, N'621-450002', N'Awarded', N'JSW Cement Ltd ( Vijayanagar)', CAST(N'2021-01-29' AS Date), CAST(N'2021-08-31' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Gaurav Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (61, 61, N'621-450003', N'Awarded', N'Shree Cement Ltd (SRCP)', CAST(N'2021-02-02' AS Date), CAST(N'2021-07-23' AS Date), NULL, N'D', N'CLP', N'Commissioned', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (62, 62, N'621-450004', N'Awarded', N'Shree Cement Ltd (SRCP)', CAST(N'2021-02-02' AS Date), CAST(N'2021-07-23' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (63, 63, N'621-450005', N'Awarded', N'KHD Humboldt Wedag India (P) Ltd', CAST(N'2021-02-02' AS Date), CAST(N'2021-07-25' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (64, 64, N'621-450006', N'Awarded', N'Shree Renuka Sugars Ltd', CAST(N'2021-02-13' AS Date), CAST(N'2021-09-30' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (65, 65, N'621-450007', N'Awarded', N'BHEL-Industrial Systems Group', CAST(N'2021-02-26' AS Date), CAST(N'2022-09-25' AS Date), NULL, N'C', N'CLS', N'On Hold', N'On Hold', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (66, 66, N'621-450008', N'Awarded', N'BHEL-Industrial Systems Group', CAST(N'2021-02-26' AS Date), CAST(N'2022-09-25' AS Date), NULL, N'C', N'CLS', N'On Hold', N'On Hold', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (67, 67, N'621-450009', N'Awarded', N'Chettinad Cement Corpn.Ltd', CAST(N'2021-03-10' AS Date), CAST(N'2021-09-09' AS Date), NULL, N'D', N'PP', N'Commissioned', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (68, 68, N'621-450010', N'Awarded', N'J.K.CEMENT LTD', CAST(N'2021-04-12' AS Date), CAST(N'2022-01-05' AS Date), CAST(N'2022-12-05' AS Date), N'C', N'PP', N'Commissioning', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-12-05 14:31:45.357' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (69, 69, N'621-450011', N'Awarded', N'Ultratech Cement Ltd  -  ( PALI)', CAST(N'2021-04-08' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (70, 70, N'621-450012', N'Awarded', N'Ultratech Cement Ltd  -  ( Dhar)', CAST(N'2021-04-08' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (71, 71, N'621-450013', N'Awarded', N'Ultratech Cement Ltd - ( Hirmi)', CAST(N'2021-03-22' AS Date), CAST(N'2021-09-11' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (72, 72, N'621-450014', N'Awarded', N'UTCL Dhule', CAST(N'2021-04-08' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (73, 73, N'621-450015', N'Awarded', N'UTCL Patliputra', CAST(N'2021-05-05' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (74, 74, N'621-450016', N'Awarded', N'UTCL Dalla', CAST(N'2021-04-27' AS Date), CAST(N'2021-10-11' AS Date), NULL, N'D', N'CLP', N'Commissioning', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (75, 75, N'621-450017', N'Awarded', N'UTCL Dhule', CAST(N'2021-03-30' AS Date), CAST(N'2021-11-30' AS Date), NULL, N'C', N'PP', N'Installation', N'Closed', N'No', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (76, 76, N'621-450018', N'Awarded', N'UTCL PATLIPUTRA', CAST(N'2021-03-30' AS Date), CAST(N'2023-01-31' AS Date), CAST(N'2021-10-30' AS Date), N'C', N'PP', N'Installation', N'Closed', N'No', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-12-27 15:36:55.230' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (77, 77, N'621-450019', N'Awarded', N'UTCL Pali', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'C', N'PP', N'Installation', N'Closed', N'No', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (78, 78, N'621-450020', N'Awarded', N'UTCL Dhar', CAST(N'2021-03-30' AS Date), CAST(N'2022-12-31' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (79, 79, N'621-450021', N'Awarded', N'UTCL Hirmi', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (80, 80, N'621-450022', N'Awarded', N'UTCL Jharsuguda', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (81, 81, N'621-450023', N'Awarded', N'UTCL Sonar Bangla', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (82, 82, N'621-450024', N'Not-Awarded', N'UTCL Dalla', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (83, 83, N'621-450025', N'Awarded', N'UTCL Neem Ka Thana', CAST(N'2021-03-30' AS Date), CAST(N'2021-10-30' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (84, 84, N'621-450026', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (85, 85, N'621-450027', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (86, 86, N'621-450028', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (87, 87, N'621-450029', N'Awarded', N'Instakart services private limited', CAST(N'2020-07-13' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'B', N'Logistics', N'Commissioning', N'Open', N'Yes', N'Ashok Rathi', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (88, 88, N'621-450030', N'Awarded', N'Chettinad Cement Corpn.Ltd Ariyalur', CAST(N'2021-04-30' AS Date), CAST(N'2021-10-29' AS Date), NULL, N'D', N'PP', N'Handover to CS', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (89, 89, N'621-450031', N'Awarded', N'ThyssenKrupp Industries India Pvt. Ltd.', CAST(N'2021-05-14' AS Date), CAST(N'2021-12-30' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (90, 90, N'621-450032', N'Awarded', N'LOESCHE INDIA PRIVATE LIMITED', CAST(N'2021-05-14' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (91, 91, N'621-450033', N'Awarded', N'LOESCHE INDIA PRIVATE LIMITED', CAST(N'2021-05-14' AS Date), CAST(N'2021-11-15' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (92, 92, N'621-450034', N'Awarded', N'Ultratech ( Manigarh Cement works)', CAST(N'2021-06-22' AS Date), CAST(N'2022-01-31' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (93, 93, N'621-450035', N'Awarded', N'Jaykay Cem (Central ) Ltd- Panna', CAST(N'2021-05-20' AS Date), CAST(N'2021-11-20' AS Date), NULL, N'C', N'CLP', N'Installation', N'Closed', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (94, 94, N'621-450037', N'Awarded', N'Jaykaycem (Central) Ltd', CAST(N'2021-05-27' AS Date), CAST(N'2022-01-24' AS Date), NULL, N'C', N'PP', N'Commissioning', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (95, 95, N'621-450038', N'Awarded', N'Wonder Cement Ltd. Chittorgarh', CAST(N'2021-06-08' AS Date), CAST(N'2022-03-08' AS Date), NULL, N'C', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (96, 96, N'621-450039', N'Awarded', N'Ultratech Cement Limited', CAST(N'2021-06-18' AS Date), CAST(N'2022-03-17' AS Date), NULL, N'C', N'CLS', N'Installation', N'Open', N'Yes', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (97, 97, N'621-450040', N'Awarded', N'Loesche India Pvt. Ltd. (A/c JSW Dolvi)', CAST(N'2021-07-15' AS Date), CAST(N'2022-01-30' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (98, 98, N'621-450041', N'Awarded', N'Ultratech Cement Ltd (APCW)', CAST(N'2021-07-23' AS Date), CAST(N'2022-02-15' AS Date), NULL, N'D', N'CLP', N'Handover to CS', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (99, 99, N'621-450042', N'Awarded', N'Penna Cement Industries Limited', CAST(N'2021-09-24' AS Date), CAST(N'2022-05-23' AS Date), NULL, N'C', N'PP', N'On Hold', N'On Hold', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (100, 100, N'621-450043', N'Awarded', N'Utratech Cement (Hirmi)', CAST(N'2021-08-10' AS Date), CAST(N'2022-01-10' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (101, 101, N'621-450044', N'Awarded', N'Utratech Cement (Jharsuguda)', CAST(N'2021-08-10' AS Date), CAST(N'2022-01-10' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (102, 102, N'621-450045', N'Awarded', N'Jaykaycem (Central) Works Hamirpur', CAST(N'2021-09-03' AS Date), CAST(N'2022-05-23' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (103, 103, N'621-450046', N'Awarded', N'Penna Cement (Marwar)', CAST(N'2021-09-07' AS Date), CAST(N'2022-06-08' AS Date), NULL, N'C', N'CLP', N'On Hold', N'On Hold', N'No', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (104, 104, N'621-450047', N'Awarded', N'Chettinad Cement Corporation Ltd', CAST(N'2021-09-15' AS Date), CAST(N'2022-08-30' AS Date), NULL, N'D', N'CLP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (105, 105, N'621-450048', N'Awarded', N'Loesche India (a/c Jaykaycem Hamirpur)', CAST(N'2021-09-21' AS Date), CAST(N'2022-04-30' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (106, 106, N'621-450049', N'Awarded', N'Dalmia Cement (Bharat) Limited (Bokaro)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'C', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (107, 107, N'621-450050', N'Awarded', N'Dalmia Bharat Green Vision Ltd. (Bihar)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'C', N'PP', N'On Hold', N'On Hold', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (108, 108, N'621-450051', N'Awarded', N'Dalmia Bharat Green Vision Ltd. (Tuticorin)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'C', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (109, 109, N'621-450052', N'Awarded', N'Dalmia Bharat Green Vision Ltd. (South Chennai)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'C', N'PP', N'On Hold', N'On Hold', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (110, 110, N'621-450053', N'Awarded', N'Dalmia Cement (Bharat) Limited (Belgaum)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'D', N'PP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (111, 111, N'621-450054', N'Awarded', N'Dalmia Cement (Bharat) Limited (Kapilas)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'D', N'PP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (112, 112, N'621-450055', N'Awarded', N'Dalmia DSP Limited (Kalyanpur)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'D', N'PP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (113, 113, N'621-450056', N'Awarded', N'Dalmia Cement (Bharat) Limited (Midnapur)', CAST(N'2021-09-20' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'D', N'PP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (114, 114, N'621-450057', N'Awarded', N'Humboldt Wedag  ( A/c Marwar Cement)', CAST(N'2021-10-14' AS Date), CAST(N'2022-04-20' AS Date), NULL, N'D', N'CLP', N'On Hold', N'On Hold', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (115, 115, N'621-450058', N'Awarded', N'ACC Limited Ametha', CAST(N'2021-10-23' AS Date), CAST(N'2022-03-23' AS Date), NULL, N'D', N'PP', N'Installation', N'Closed', N'No', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (116, 116, N'621-450059', N'Awarded', N'Ultratech Cement Narmada Cement Magdalla', CAST(N'2021-11-10' AS Date), CAST(N'2022-09-30' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Closed', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (117, 117, N'621-450062', N'Awarded', N'Hindustan Zinc Limited', CAST(N'2021-12-07' AS Date), CAST(N'2022-10-07' AS Date), NULL, N'C', N'CLS', N'Production', N'Open', N'Yes', N'Jinendra Jain', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (118, 118, N'622-450001', N'Awarded', N'Murli Industries Ltd. (Dalmia)', CAST(N'2021-12-28' AS Date), CAST(N'2022-08-20' AS Date), NULL, N'D', N'PP', N'Commissioning', N'Closed', N'No', N'Abhishek Chaudhary', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (119, 119, N'622-450002', N'Awarded', N'Gebr. Pfeiffer (Mombasa Athi River)', CAST(N'2021-12-16' AS Date), CAST(N'2022-09-30' AS Date), NULL, N'D', N'CLP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (120, 120, N'622-450003', N'Awarded', N'Gebr. Pfeiffer (Tororo Cement)', CAST(N'2021-12-16' AS Date), CAST(N'2022-09-30' AS Date), NULL, N'D', N'CLP', N'Supply Closed', N'Closed', N'No', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (121, 121, N'622-450004', N'Awarded', N'Shree Cement Purulia Plant', CAST(N'2021-12-31' AS Date), CAST(N'2022-08-14' AS Date), NULL, N'C', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (122, 122, N'622-450005', N'Awarded', N'Shree Cement Purulia Plant', CAST(N'2021-12-29' AS Date), CAST(N'2022-08-14' AS Date), NULL, N'D', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (123, 123, N'622-450006', N'Awarded', N'Shree Cement Limited Nawalgarh', CAST(N'2021-12-31' AS Date), CAST(N'2022-08-14' AS Date), NULL, N'C', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (124, 124, N'622-450007', N'Awarded', N'SHREE CEMENT LIMITED NAWALGARH', CAST(N'2021-12-29' AS Date), CAST(N'2023-01-31' AS Date), CAST(N'2022-08-14' AS Date), N'D', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-12-27 15:35:38.957' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (125, 125, N'622-450008', N'Awarded', N'SHREE CEMENT LIMITED NAWALGARH', CAST(N'2022-01-01' AS Date), CAST(N'2023-02-28' AS Date), CAST(N'2022-08-14' AS Date), N'D', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-12-27 15:36:18.180' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (126, 126, N'622-450009', N'Awarded', N'Loesche India Pvt Ltd. (JK Lakshmi)', CAST(N'2021-12-02' AS Date), CAST(N'2021-06-02' AS Date), NULL, N'D', N'CLP', N'Installation', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (127, 127, N'622-450010', N'Awarded', N'Salzgitter Mannesmann International GmbH (Mombasa)', CAST(N'2022-02-14' AS Date), CAST(N'2022-11-30' AS Date), NULL, N'C', N'CLP', N'Under Supply', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (128, 128, N'622-450012', N'Awarded', N'JSW Cement Ltd.', CAST(N'2022-02-16' AS Date), CAST(N'2022-09-30' AS Date), NULL, N'D', N'PP', N'Under Supply', N'Open', N'Yes', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (129, 129, N'622-450013', N'Awarded', N'Adani Cement Industries Limited', CAST(N'2022-02-17' AS Date), CAST(N'2023-01-25' AS Date), NULL, N'C', N'PP', N'Under Supply', N'Open', N'Yes', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (130, 130, N'622-450014', N'Awarded', N'Humboldt Wedag India Pvt. Ltd.', CAST(N'2022-02-14' AS Date), CAST(N'2022-09-09' AS Date), NULL, N'D', N'CLP', N'On Hold', N'On Hold', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (131, 131, N'622-450015', N'Awarded', N'Humboldt Wedag India Pvt. Ltd.', CAST(N'2022-02-14' AS Date), CAST(N'2022-09-09' AS Date), NULL, N'D', N'CLP', N'Supply Closed', N'Closed', N'No', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (132, 132, N'622-450016', N'Awarded', N'Solcon Engineers Pvt. Ltd. (Adani Dahej)', CAST(N'2022-04-01' AS Date), CAST(N'2022-12-20' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (133, 133, N'622-450017', N'Awarded', N'Shree Cement Limited Nawalgarh', CAST(N'2022-04-13' AS Date), CAST(N'2022-12-31' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (134, 134, N'622-450018', N'Awarded', N'WONDER CEMENT ALIGARH', CAST(N'2022-04-11' AS Date), CAST(N'2023-01-31' AS Date), CAST(N'2022-11-10' AS Date), N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-12-28 10:50:37.520' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (135, 135, N'622-450019', N'Awarded', N'Wonder Cement Tulsigam', CAST(N'2022-04-11' AS Date), CAST(N'2022-11-10' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (136, 136, N'622-450021', N'Awarded', N'Shree Cement Ltd.', CAST(N'2022-05-25' AS Date), CAST(N'2023-02-15' AS Date), NULL, N'C', N'CLP', N'Under Supply', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (137, 137, N'622-450022', N'Awarded', N'SHREE PURULIA CEMENT PLANT (A UNIT OF SHREE CEMENT', CAST(N'2021-05-11' AS Date), CAST(N'2023-03-18' AS Date), NULL, N'D', N'CLP', N'Under Supply', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (138, 138, N'622-450023', N'Awarded', N'JSW Cement Ltd.', CAST(N'2022-05-20' AS Date), CAST(N'2023-06-27' AS Date), NULL, N'C', N'PP', N'Production', N'Open', N'Yes', N'Vivek Krishna Gupta', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (139, 139, N'622-450024', N'Awarded', N'CTS-NTE-JV Nepal', CAST(N'2022-05-30' AS Date), CAST(N'2022-10-31' AS Date), NULL, N'D', N'Airports ', N'Under Supply', N'Open', N'Yes', N'Ragav Raghunath', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (140, 140, N'622-450025', N'Awarded', N'LOESCHE INDIA PRIVATE LIMITED', CAST(N'2022-06-01' AS Date), CAST(N'2023-01-21' AS Date), NULL, N'D', N'CLP', N'Production', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (141, 141, N'622-450027', N'Awarded', N'Humboldt Wedag India Pvt. Ltd.', CAST(N'2022-07-20' AS Date), CAST(N'2023-01-31' AS Date), NULL, N'D', N'CLP', N'Production', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (142, 142, N'622-450028', N'Awarded', N'Ultratech Cement Limited (UTCL) Unit - Dankuni Cem', CAST(N'2022-08-11' AS Date), CAST(N'2022-03-10' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (143, 143, N'622-450029', N'Awarded', N'J.K.Cement Ltd', CAST(N'2022-08-08' AS Date), CAST(N'2022-07-31' AS Date), NULL, N'C', N'PP', N'Design', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (144, 144, N'622-450031', N'Awarded', N'Dalmia Cement (Bharat) Limited - Bokaro', CAST(N'2022-08-18' AS Date), CAST(N'2023-01-31' AS Date), NULL, N'D', N'PP', N'Under Supply', N'Open', N'Yes', N'Ravikant Mittal', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (145, 145, N'622-450032', N'Awarded', N'Star Cement Meghalaya', CAST(N'2022-09-15' AS Date), CAST(N'2022-06-15' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (146, 146, N'622-450033', N'Awarded', N'JSW Cement Ltd.', NULL, NULL, NULL, N'D', N'CLS', N'Production', N'Open', N'Yes', N'Nitin Kaushik', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (147, 147, N'622-450037', N'Awarded', N'UTCL Dadri', CAST(N'2022-10-17' AS Date), CAST(N'2023-05-15' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (148, 148, N'622-450038', N'Awarded', N'Star Cement Meghalaya', CAST(N'2022-10-29' AS Date), CAST(N'2022-04-29' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (149, 149, N'622-450039', N'Awarded', N'Tororo Cement Limited', NULL, NULL, NULL, N'C', N'PP', N'Design', N'Open', N'Yes', N'Avneet Arora', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (150, 150, N'622-450040', N'Awarded', N'Ramco Cement Limited', CAST(N'2022-11-15' AS Date), CAST(N'2022-06-25' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (151, 151, N'622-450041', N'Awarded', N'Hills Cement Limited', CAST(N'2022-11-22' AS Date), CAST(N'2022-06-30' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Sachin Saini', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (152, 152, N'622-450043', N'Awarded', N'UTCL APCW', CAST(N'2022-11-04' AS Date), CAST(N'2023-08-04' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (153, 153, N'622-450044', N'Awarded', N'UTCL Arrakonam', CAST(N'2022-11-04' AS Date), CAST(N'2023-07-04' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (154, 154, N'622-450045', N'Awarded', N'UTCL Kotputli', CAST(N'2022-11-04' AS Date), CAST(N'2023-07-04' AS Date), NULL, N'C', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (155, 155, N'622-450046', N'Awarded', N'UTCL BSBT', CAST(N'2022-11-04' AS Date), CAST(N'2023-07-04' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (156, 156, N'622-450047', N'Awarded', N'UTCL Roorkee', CAST(N'2022-11-04' AS Date), CAST(N'2023-07-04' AS Date), NULL, N'D', N'CLP', N'Design', N'Open', N'Yes', N'Satyendra Sinha', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (157, 157, N'821-450572', N'Awarded', N'DELHI METRO RAIL CORPORATION', NULL, NULL, NULL, N'D', N'Airports ', N'Design', N'Closed', N'No', N'Amit Verma', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
INSERT [dbo].[tblProject] ([RecId], [ProjectID], [ProjectCode], [ProjectType], [ProjectName], [ProjectStartDate], [ProjectEndDate], [OldProjectEndDate], [ProjectCategory], [ProjectSegment], [ProjectStage], [ProjectStatus], [Reporting], [ProjectManager], [OperatorName], [LastEditTime]) VALUES (158, 158, N'822-450510', N'Awarded', N'Lucknow ', NULL, NULL, NULL, N'D', N'Airports ', N'Design', N'Open', N'Yes', N'Ragav Raghunath', N'Admin', CAST(N'2022-11-29 00:00:00.000' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[tblProject] OFF
GO
SET IDENTITY_INSERT [dbo].[tblTask] ON 

GO
INSERT [dbo].[tblTask] ([RecID], [EmpID], [ProjectID], [ProjectCode], [PMonth], [PYear], [Task]) VALUES (1, N'700039', N'156', N'622-450047', N'December', N'2022', N'Documentation')
GO
INSERT [dbo].[tblTask] ([RecID], [EmpID], [ProjectID], [ProjectCode], [PMonth], [PYear], [Task]) VALUES (2, N'703809', N'144', N'622-450031', N'January', N'2023', N'Testing')
GO
INSERT [dbo].[tblTask] ([RecID], [EmpID], [ProjectID], [ProjectCode], [PMonth], [PYear], [Task]) VALUES (3, N'703809', N'38', N'620-450012', N'January', N'2023', N'testing for new')
GO
SET IDENTITY_INSERT [dbo].[tblTask] OFF
GO
USE [master]
GO
ALTER DATABASE [Beumer_Group3] SET  READ_WRITE 
GO
