-- ########################################### Aggregate function for daily average per station
SELECT
	STATION,
    TRUNC(MEASURE_DATE,'DD') DATE_MEASURED, 
    ROUND(AVG(VALUE),2) DAY_AVG
FROM 
	T_CLIMATE_TEMPERATURE_10MIN
GROUP BY 
	STATION,
	TRUNC(MEASURE_DATE,'DD')
ORDER BY
    STATION,
    2 -- TRUNC(MEASURE_DATE,'DD')
        
;
    
-- ########################################### CTE Window function for daily station average with value more than 5

WITH DAILY_AVG_TMP as (
SELECT
	DISTINCT STATION,
    TRUNC(MEASURE_DATE,'DD') DATE_MEASURED,
    ROUND(AVG(VALUE) OVER (PARTITION BY STATION, TRUNC(MEASURE_DATE,'DD')),2) DAY_AVG
FROM 
	T_CLIMATE_TEMPERATURE_10MIN
ORDER BY 1)
SELECT
	STATION,
    DATE_MEASURED,
    DAY_AVG
FROM
    DAILY_AVG_TMP
WHERE
    DAY_AVG > 5
;

-- ###########################################  Aggregate function for daily station average more than 5

SELECT
	STATION,
    TRUNC(MEASURE_DATE,'DD') DATE_MEASURED,
    ROUND(AVG(VALUE),2) DAY_AVG
FROM
    T_CLIMATE_TEMPERATURE_10MIN
GROUP BY 
	STATION, 
	TRUNC(MEASURE_DATE,'DD')
HAVING
    ROUND(AVG(VALUE),2) > 5
ORDER BY
    STATION,
    2
    
;

-- ########################################### LISTAGG for hourly averages by day per station
/*
################################################################################################################################################################
    DATE        Topic       Comment                                                                                         RESULT
    2026.02.26  - Issue:    LISTAGG shows values as ordered by value not in order of hours
################################################################################################################################################################
*/

SELECT
	DISTINCT
    STATION,
    TO_CHAR(DATE_MEASURED,'YYYY-MM-DD') DATE_MEASURED,
    --LISTAGG(DATE_MEASURED, ',') WITHIN GROUP (ORDER BY DATE_MEASURED),
    LISTAGG(HOUR_AVG, '; ') WITHIN GROUP (ORDER BY DATE_MEASURED) OVER (PARTITION BY TO_CHAR(DATE_MEASURED,'YYYY-MM-DD')) "Day list"
FROM
    (
    SELECT  
		STATION,
        TRUNC(DATE_MEASURED,'HH24') DATE_MEASURED,
        HOUR_AVG
    FROM
        (
        SELECT
			STATION,
            TRUNC(MEASURE_DATE, 'HH24') DATE_MEASURED,
            ROUND(AVG(VALUE),2) HOUR_AVG
        FROM
            T_CLIMATE_TEMPERATURE_10MIN
        GROUP BY
			STATION, 
            TRUNC(MEASURE_DATE, 'HH24')
        ORDER BY
            STATION,
            TRUNC(MEASURE_DATE, 'HH24')
        )
    )
--GROUP BY
--	STATION,
--    DATE_MEASURED
ORDER BY
    STATION,
    DATE_MEASURED
;
-- ########################################### Pivot for hourly averages by day per station

WITH DAILY_AVG AS (
    SELECT
        STATION,
        TO_CHAR(DATE_MEASURED,'YYYY-MM-DD') DATE_MEASURED,
        HH,
        AVG_HOUR
    FROM (
        SELECT
            STATION,
            TRUNC(MEASURE_DATE,'HH24') DATE_MEASURED,
            TO_CHAR(MEASURE_DATE,'HH24') HH,
            ROUND(avg(value),2) AVG_HOUR
        FROM
            T_CLIMATE_TEMPERATURE_10MIN 
        GROUP BY 
            STATION,
            TRUNC(MEASURE_DATE,'HH24'), 
            TO_CHAR(MEASURE_DATE,'HH24')
        ORDER BY
            STATION, 
            TRUNC(MEASURE_DATE,'HH24'),
            TO_CHAR(MEASURE_DATE,'HH24')
        )
    )
SELECT
    STATION,
    DATE_MEASURED, 
    HH00, HH01, HH02, HH03, HH04, HH05, HH06, HH07, HH08, HH09, HH10, HH11, 
    HH12, HH13, HH14, HH15, HH16, HH17, HH18, HH19, HH20, HH21 HH22, HH23
FROM DAILY_AVG
PIVOT (MAX(AVG_HOUR) FOR HH IN ('00' as HH00, '01' as HH01, '02' as HH02, '03' as HH03, '04' as HH04, '05' as HH05, '06' as HH06, '07' as HH07, '08' as HH08, '09' as HH09, '10' as HH10, '11' as HH11, '12' as HH12,
                        '13' as HH13, '14' as HH14, '15' as HH15, '16' as HH16, '17' as HH17, '18' as HH18, '19' as HH19, '20' as HH20, '21' as HH21, '22' as HH22, '23' as HH23))
ORDER BY
    STATION,
    DATE_MEASURED
;
-- ########################################### Variance for daily min, max, variance and standard deviation

SELECT
	DISTINCT STATION,
    TRUNC(MEASURE_DATE, 'DD') DATE_MEASURED,
    MIN(VALUE) OVER (PARTITION BY STATION, TRUNC(MEASURE_DATE, 'DD')) MIN,
    MAX(VALUE) OVER (PARTITION BY STATION, TRUNC(MEASURE_DATE, 'DD'))MAX,
    ROUND(VARIANCE(VALUE) OVER (PARTITION BY STATION, TRUNC(MEASURE_DATE, 'DD')),2) VARIANCE,
    ROUND(STDDEV(VALUE) OVER (PARTITION BY STATION, TRUNC(MEASURE_DATE, 'DD')),2) STDDEV
FROM
    T_CLIMATE_TEMPERATURE_10MIN
ORDER BY 
    STATION,
    TRUNC(MEASURE_DATE, 'DD')
;

-- ########################################### XML Construction
/*
################################################################################################################################################################
    DATE        Topic       Comment                                                                                         RESULT
    2026.02.26  - Issue:    Not functional at the moment
################################################################################################################################################################
*/
SELECT XMLELEMENT("dept_list",
         XMLAGG (
           XMLELEMENT("dept",
             XMLATTRIBUTES(d.deptno AS "deptno"),
             XMLFOREST(
               d.deptno AS "deptno",
               d.dname AS "dname",
               d.loc AS "loc",
               (SELECT XMLAGG(
                         XMLELEMENT("emp",
                           XMLFOREST(
                             e.empno AS "empno",
                             e.ename AS "ename",
                             e.job AS "job",
                             e.mgr AS "mgr",
                             e.hiredate AS "hiredate",
                             e.sal AS "sal",
                             e.comm AS "comm"
                           )
                         )
                       )
                FROM   emp e
                WHERE  e.deptno = d.deptno
               ) "emp_list"
             )
           )
         )
       ) AS "depts"
FROM   dept d
WHERE  d.deptno = 10;


SELECT
    XMLELEMENT("station",
            XMLATTRIBUTES(station as "id"),
                XMLELEMENT("date",
                    XMLATTRIBUTES(TRUNC(measure_date,'DD') as "date"),
                    XMLELEMENT
                            (XMLFOREST("day",
                                (SELECT XMLAGG(  
                                        XMLELEMENT("values",
                                                XMLFOREST( 
                                                       TO_CHAR(measure_date,'HH24') as "hour",
                                                        value as "value"
                                                    ) "values"
                                                )
                                            )
                            FROM 
                                T_CLIMATE_TEMPERAUTURE_10MIN h
                            WHERE h.station=tct.station
                            )
                        )
                    )
                )
FROM
    T_CLIMATE_TEMPERATURE_10MIN tct
order by station, measure_date
;
