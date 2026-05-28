 /****************************************************************/
 /*           S A S   S A M P L E   L I B R A R Y                */
 /*                                                              */
 /*    NAME:  Chart                                              */
 /*   TITLE:  Generating Hbar, Vbar, Block, Pie, and Star Charts */
 /* PRODUCT:  SAS                                                */
 /*  SYSTEM:  ALL                                                */
 /*    KEYS:  HISTOGRAM, BAR CHART, BLOCK CHART, PIE CHART,      */
 /*    KEYS:  STAR CHART,                                        */
 /*   PROCS:  CHART FREQ                                         */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT:  HHR                        UPDATE:  03Jun87        */
 /*     REF:                                                     */
 /*    MISC:                                                     */
 /****************************************************************/
/* ok.. */
 /****************************************************************/
 /*    The following data step generates January 1979 daily      */
 /* revenues for a company with branches in four cities:         */
 /* Chicago, Los Angeles, New York, and Raleigh.  Each branch    */
 /* reports revenues for three departments:  100, 115, and 314.  */
 /* PROC CHART is used to generate various hbar, vbar, block,    */
 /* and pie charts showing the distribution of revenues over     */
 /* branches and departments.                                    */
 /****************************************************************/

options ls=78 ps=60 nodate;

data jan;
   length c1-c4 city $ 15;
   array c{4} $ c1-c4;
   retain
      c1 'Chicago, IL'
      c2 'Los Angeles, CA'
      c3 'New York, NY'
      c4 'Raleigh, NC'
      seed 080549;
   month = 1;
   year = 87;
   keep city cityno dept date dow week weekinv revenue;
   format date date7. revenue dollar8.;

   /* compute offsets and maxima */
   fday = weekday( mdy( month, 1, year )) - 1;
   if month ^= 12 then
      maxdays = mdy( month + 1, 1, year ) - mdy( month, 1, year );
   else
      maxdays = 31;
   lday = 7 - weekday( mdy( month, maxdays, year )) + 1;
   maxweeks = ceil(( maxdays - 1 + lday ) / 7 );

   /* for all cities, all departments, all weekdays, generate revenues*/
   do cityno = 1 to 4;
      city = c{ cityno };
      do dept = 100, 115, 314;
         do day = 1 to maxdays;
            date = mdy( month, day, year );
            wkday = weekday( date );
            if( 2 <= wkday <= 6 ) then do;
               week = ceil(( fday + day( date )) / 7 );
               weekinv = ceil(( maxdays - day + lday ) / 7 ) +
                  ( 6 - maxweeks );
               dow = put( date, weekdate9.);
               dow = scan( dow, 1 );
               dow = upcase( dow );
               x = uniform( seed );
               if x < .25 then
                  revenue = 1453 * uniform( seed );
               else if .25 <= x <= .58 then
                  revenue = 1000 * uniform( seed );
               else if .98 <= x <= .99 then
                  revenue = 2600 * uniform( seed );
               else
                  revenue =  500 * uniform( seed );
               p = 0;
               if wkday = 3 or wkday = 6 then
                  p = .1;
               if wkday = 4 then
                  p = .2;
               if wkday = 5 then
                  p = .3;
               revenue = p * revenue + revenue + cityno * 100;
               output;
            end;
         end;
      end;
   end;
   label  dow = 'Day of the Week'
         week = 'Week of the Month'
      weekinv = 'Week of the Month';
   run;

proc freq;
   tables city*dept / nopercent norow nocol;
   weight revenue;
   run;

title1 'vbar dept / subgroup=city sumvar=revenue discrete;';
title2 '(vertical bar chart of revenue sums by dept and city)';
title4 'January 1987 Revenue Report';
proc chart;
   vbar dept / subgroup=city sumvar=revenue discrete;
   run;

proc chart;
   hbar dept / subgroup=city sumvar=revenue discrete;
   run;

title1 'hbar dept / group=city sumvar=revenue discrete;';
title2 '(horizontal bar chart of revenue sums by dept and city)';
title4 'January 1987 Revenue Report';
proc chart;
   hbar dept / group=city sumvar=revenue discrete;
   run;

title1 'block dept / group=city sumvar=revenue discrete;';
title2 '(block chart of revenue sums by dept and city)';
title4 'January 1987 Revenue Report';
proc chart;
   block dept / group=city sumvar=revenue discrete;
   run;

title1 'pie city / sumvar=revenue discrete;';
title2 '(pie chart of revenue sums by city)';
title4 'January 1987 Revenue Report';
proc chart;
   pie city / sumvar=revenue discrete;
   run;

title1 'pie city / type=mean sumvar=revenue discrete;';
title2 '(pie chart of mean revenue per day by city)';
title4 'January 1987 Revenue Report';
proc chart;
   pie city / type=mean sumvar=revenue discrete;
   run;


 /****************************************************************/
 /*    The data below represents total revenues for each month   */
 /* of 1987, for a rapidly growing company.  PROC CHART is used  */
 /* to produce a star chart and a vertical bar chart showing     */
 /* revenues increasing over the year.  Note the star chart may  */
 /* be thought of as simply a different sort of bar chart, with  */
 /* all the bars radiating from a central point.  The principal  */
 /* advantage of the star chart in this example is it allows     */
 /* easy comparison of the last bar with the first.              */
 /****************************************************************/

data jandec;
   input month $ 1-3 revenue;
   list;
   cards;
Jan   362704
Feb   353000
Mar   400405
Apr   420550
May   450600
Jun   500765
Jul   500070
Aug   600065
Sep   750700
Oct   800770
Nov   944085
Dec   990550
;

title1 'star month / sumvar=revenue midpoints=''Jan''...';
title2 '(star chart of revenue per month)';
title4 'January 1987 Revenue Report';
proc chart;
   star month / sumvar=revenue midpoints='Jan' 'Feb' 'Mar'
      'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec';
   format revenue dollar8.;
   run;

title1 'vbar month / sumvar=revenue midpoints=''Jan''...';
title2 '(vertical bar chart of revenue per month)';
title4 'January 1987 Revenue Report';
proc chart;
   vbar month / sumvar=revenue midpoints='Jan' 'Feb' 'Mar'
      'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec';
   format revenue dollar8.;
   run;
