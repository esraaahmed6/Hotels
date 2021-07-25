-- Table Creation

ALTER TABLE ITI.DATE_DIM
 DROP PRIMARY KEY CASCADE;

DROP TABLE ITI.DATE_DIM CASCADE CONSTRAINTS;

CREATE TABLE ITI.DATE_DIM
(
  DATE_KEY                     NUMBER,
  FULL_DATE                    DATE,
  FULL_DATE_DESCRIPTION        VARCHAR2(64 BYTE),
  DAY_OF_WEEK                  NUMBER(1),
  DAY_OF_MONTH                 NUMBER(2),
  DAY_OF_YEAR                  NUMBER(3),
  LAST_DAY_OF_WEEK_INDICATOR   CHAR(1 BYTE),
  LAST_DAY_OF_MONTH_INDICATOR  CHAR(1 BYTE),
  WEEK_ENDING_DATE             DATE,
  MONTH_NUMBER                 NUMBER(2),
  MONTH_NAME                   VARCHAR2(32 BYTE),
  YEAR_MONTH                   CHAR(32 BYTE),
  QUARTER_NUMBER               NUMBER(1),
  YEAR_QUARTER                 CHAR(32 BYTE),
  YEAR_NUMBER                  NUMBER(4)
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX ITI.DATE_DIM_PK ON ITI.DATE_DIM
(DATE_KEY)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE ITI.DATE_DIM ADD (
  CONSTRAINT DATE_DIM_PK
 PRIMARY KEY
 (DATE_KEY)
    USING INDEX 
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));



-- Procedure 
CREATE OR REPLACE PROCEDURE ITI.Generate_DATE_DIM(v_START_YEAR IN INT, v_END_YEAR IN INT) AS

--Declare two variables as DATE datatypes
v_CURRENT_DATE DATE;
v_END_DATE     DATE;
v_LAST_DAY_OF_WEEK_INDICATOR Char;
v_LAST_DAY_OF_MONTH_INDICATOR Char;
v_WEEK_ENDING_DATE DATE;
v_Date_Key Number;
BEGIN

--Assign the start year and end year to it's respective variables
v_CURRENT_DATE := TO_DATE('0101' || v_START_YEAR, 'MMDDYYYY');
v_END_DATE     := TO_DATE('1231' || v_END_YEAR,   'MMDDYYYY');

--Clear/Dump what is currently stored in the table
DELETE FROM DATE_DIM;

--Check the condition to see if the start year is less than the end year (Input Parameters)
WHILE v_CURRENT_DATE <= v_END_DATE
LOOP
--DATE_DIMENSION Table

Select 
        TO_NUMBER(TO_CHAR(v_CURRENT_DATE, 'DDMMYYYY')) ,
        (CASE                                            --LAST_DAY_OF_WEEK_INDICATOR
        WHEN TO_CHAR(v_CURRENT_DATE,'FMDay') = 'Saturday' THEN 'Y'
        ELSE 'N'  
        END ) , 
        (CASE                                            --LAST_DAY_OF_MONTH_INDICATOR
        WHEN LAST_DAY(v_CURRENT_DATE) =v_CURRENT_DATE THEN 'Y'
        ELSE 'N'
    END) ,
    (CASE                                            --WEEK_ENDING_DATE OF CURRENT WEEK ENDING ON SATURDAY
        WHEN TO_CHAR(v_CURRENT_DATE,'FMDay') = 'Saturday' THEN v_CURRENT_DATE
        ELSE NEXT_DAY(v_CURRENT_DATE,'SATURDAY')
    END)
Into v_Date_Key, v_LAST_DAY_OF_WEEK_INDICATOR , v_LAST_DAY_OF_MONTH_INDICATOR , v_WEEK_ENDING_DATE
from dual;
    
INSERT INTO DATE_DIM
(
    DATE_KEY,
    FULL_DATE,
    FULL_DATE_DESCRIPTION,
    DAY_OF_WEEK,
    DAY_OF_MONTH,
    DAY_OF_YEAR,
    LAST_DAY_OF_WEEK_INDICATOR,
    LAST_DAY_OF_MONTH_INDICATOR,
    WEEK_ENDING_DATE,
    MONTH_NUMBER,
    MONTH_NAME,
    YEAR_MONTH,
    QUARTER_NUMBER,
    YEAR_QUARTER,
    YEAR_NUMBER       
)    
VALUES
(
    v_Date_Key , --DATE_KEY
    v_CURRENT_DATE,     -- FULL Date                           
    TO_CHAR(v_CURRENT_DATE, 'Day, Month DD, YYYY'), --FULL_DATE_DESCRIPTION
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE, 'D')) -1,     --DAY_OF_WEEK
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE,'DD')),                   --DAY_OF_MONTH        
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE,'DDD')),                  --DAY_OF_YEAR
    
    v_LAST_DAY_OF_WEEK_INDICATOR ,
    v_LAST_DAY_OF_MONTH_INDICATOR ,
    v_WEEK_ENDING_DATE ,
    
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE,'MM')),                   --MONTH_NUMBER
    TO_CHAR(v_CURRENT_DATE,'MONTH'),                --MONTH_NAME
    TO_CHAR(v_CURRENT_DATE,'MONTH YYYY'),           --YEAR_MONTH        
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE,'Q')),                    --QUARTER_NUMBER
    TO_CHAR(v_CURRENT_DATE,'YYYY Q'),               --YEAR_QUARTER
    TO_NUMBER(TO_CHAR(v_CURRENT_DATE,'YYYY'))                  --YEAR_NUMBER    

);
--Increment and assign the current date value to be re-evaluated
v_CURRENT_DATE := v_CURRENT_DATE + 1;

END LOOP;
END;
/





-- Procedure Call
Declare
	v_START_YEAR NUMBER;
	v_END_YEAR NUMBER;
BEGIN
	v_START_YEAR := 2005;
	v_END_YEAR := 2020;
	ITI.Generate_DATE_DIM(v_START_YEAR, v_END_YEAR);
	Commit;
End;



