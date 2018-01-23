Compounding returns over months

Original topc:  proc expand convert from day to month

WPS datastep and WPS IML gave the same results as SAS

Nice solution by Art

Two Solutions

   1. Art datastep  WPS
   2. K Sharp IML   WPS

see
https://goo.gl/kBjfAU
https://communities.sas.com/t5/SAS-Procedures/proc-expand-convert-from-day-to-month/m-p/429871

Art's profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/13711

Ksharp profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/18408

INPUT
=====

Algorithm

    1. I first.YYMM  amt =1+ret and  cumret=amt  ==> cumret=9   1st ob
    2. else amt =1+ret and cumret = cumret*amt   ==> cumret=81  2nd ob
    3. if last.YYMM then cumret=cumret-1

WORK.HAVE total obs=15

Obs     YYMM     RET |                    RULES
                     |                    =====
  1    200001     8  |   amt =1+ret = 8+1 = 9 -> if first cumret=9
  2    200001     8  |   amt =1+ret = 8+1 = 9 -> cumret*amt= 9*9  -> cumret = 81
  3    200001     7  |   amt =1+ret = 7+1 = 8 -> cumret*amt= 81*8 -> cumret = 648
  4    200001     8  |   amt =1+ret = 8+1 = 9 -> cumret*amt=648*9 -> cumret = 5832
  5    200001     0  |   amt =1+ret = 0+1 = 1 -> cumret*amt=5832*1-> cumret = 5832
                     |   if last.yymm then cumret=cumret-1 = 5832-1 = 5831
                     |
  6    200002     9  |   amt=10   cumret=10
  7    200002     3  |   amt=4    cumret*amt=40    cumret=40
  8    200002     0  |   amt=1    cumret*amt=40    cumret=40
  9    200002     5  |   amt=6    cumret*amt=40*6  cumret=240
                     |   if last.yymm then cumret=cumret-1 = 239
 10    200003     1  |
 11    200003     0  |
 12    200003     8  |
 13    200003     1  |
 14    200003     7  |
 15    200003     4  |  cumret=1439


PROCESS ( all the code)

  Datastep

     data want;
       retain cumret;
       set need;
       by  yymm;
       amt=1+ret;
       if first.yymm then cumret=amt;
       else cumret=cumret*amt;
       if last.yymm then do;
         cumret=cumret-1;
         output;
       end;
     run;

   IML

     proc iml;
     use have;
     read all var{yymm ret};
     close;
     levels=t(unique(yymm));
     cum_ret= j(nrow(levels),1);
     do i=1 to nrow(levels);
       idx=loc(yymm=levels[i]);
       cum_ret[i]=cuprod(ret[idx]+1)[ncol(idx)]-1;
     end;
     create want var{levels cum_ret};
     append;
     close;
     quit;
*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

 WPS datastep

 WORK.WANTWPS  total obs=3

   YYMM     CUMRET

  200001     5831
  200002      239
  200003     1439

WPS IML

 WORK.WANTIML total obs=3

  LEVELS    CUM_RET

  200001      5831
  200002       239
  200003      1439

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
 input YYMM RET;
cards4;
200001 8
200001 8
200001 7
200001 8
200001 0
200002 9
200002 3
200002 0
200002 5
200003 1
200003 0
200003 8
200003 1
200003 7
200003 4
;;;;
run;quit;
*                         _       _            _
__      ___ __  ___    __| | __ _| |_ __ _ ___| |_ ___ _ __
\ \ /\ / / '_ \/ __|  / _` |/ _` | __/ _` / __| __/ _ \ '_ \
 \ V  V /| |_) \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |
  \_/\_/ | .__/|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/
         |_|                                          |_|
;
%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wrk.wantwps;
  retain yymm cumret;
  keep yymm cumret;
  set wrk.have;
  by  yymm;
  amt=1+ret;
  if first.yymm then cumret=amt;
  else cumret=cumret*amt;
  if last.yymm then do;
    cumret=cumret-1;
    output;
  end;
run;quit;
');

*                     _           _
__      ___ __  ___  (_)_ __ ___ | |
\ \ /\ / / '_ \/ __| | | '_ ` _ \| |
 \ V  V /| |_) \__ \ | | | | | | | |
  \_/\_/ | .__/|___/ |_|_| |_| |_|_|
         |_|
;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc iml;
use wrk.have;
read all var{yymm ret};
close;
levels=t(unique(yymm));
cum_ret= j(nrow(levels),1);
do i=1 to nrow(levels);
  idx=loc(yymm=levels[i]);
  cum_ret[i]=cuprod(ret[idx]+1)[ncol(idx)]-1;
end;
create wrk.wantiml var{levels cum_ret};
append;
close;
quit;
');
