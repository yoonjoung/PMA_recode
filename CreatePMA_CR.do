* This do file creates recode datafiles using public datasets
* AND non-public data for consultancy 

* Sections A, B, & D are country specific 

clear 
clear matrix
clear mata
set more off
set mem 300m
set maxvar 9000

************************************************************************ 
* A. SETTING 
************************************************************************ 
* run the python file with the downloaded public files 

global data "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\"
cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\"
dir 

#delimit;
global surveylist " 
	BFP1 CDKinshasaP1 CDKongoCentralP1 KEP1 NGLagosP1 NGKanoP1
	";
	#delimit cr

	*FR7 

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)
local todaystata=clock("`today'", "DMY")	

************************************************************************
* B. PREP
************************************************************************

**************************************************
* B.1 extract only Kano & Lagos from Nigeria
**************************************************

#delimit;
use "$data/rawCEI/CEI_NGP1_Kano_Lagos.dta", clear; keep if state==2; save "$data/rawCEI/CEI_NGLagosP1.dta", replace ; 
use "$data/rawCEI/CEI_NGP1_Kano_Lagos.dta", clear; keep if state==4; save "$data/rawCEI/CEI_NGKanoP1.dta", replace;
#delimit cr	

**************************************************
* B.2 extract Kinshasa and Kongo Cnetral 
**************************************************	

#delimit;
use "$data/rawCEI/CEI_CDP1.dta", clear; keep if province==1; save "$data/rawCEI/CEI_CDKinshasaP1.dta", replace ; 
use "$data/rawCEI/CEI_CDP1.dta", clear; keep if province==2; save "$data/rawCEI/CEI_CDKongoCentralP1.dta", replace ; 
#delimit cr	
		
************************************************************************
* C. create RECODE SDP variables
************************************************************************
	
	foreach survey in $surveylist{
		use "$data/rawCEI/CEI_`survey'.dta", clear

	* 0. Drop obs with no ID 
		drop if facility_ID==. /*should be none*/

	* 1. KEEP only complete interviews 
		
		keep if CEI_result==1

	* 2. BASIC variables and manage missing/na recode
		
		gen xsurvey="`survey'"	
		
		capture confirm variable phase
			if !_rc {
			tostring(phase), replace
			}
			else{
				gen phase=substr(xsurvey, -1, 1)
			}		
				
		replace phase = "1" if phase=="Phase1"
		destring(phase), replace		
		
		gen round=.
			replace round=6+phase if country=="Burkina Faso"
			replace round=7+phase if country=="Kenya"
			replace round=5+phase if country=="Nigeria"
			replace round=7+phase if country=="DRC"
			
		gen interview_yr = substr(today, 1, 4)
		gen interview_mo = substr(today, 6, 2)
			destring(interview_yr), replace
			destring(interview_mo), replace
			
		gen interview_cmc 	= 12*(interview_yr - 1900) + interview_mo		
			
		lab var interview_mo "interview date, month"
		lab var interview_yr "interview date, year"
		lab var interview_cmc "interview date, CMC"

		/*
		foreach x of varlist provided_* stock_* stockout_3mo_*{
			replace `x'=. if `x'<0
			}
		*/
		tab interview_yr xsurvey, m
		save "$data/CR_`survey'.dta", replace
		}
	
************************************************************************
* D. Non-public data for consultancy - including massive renaming variables... 
************************************************************************

/*
cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\NonPublicFiles\"
dir
*/
/***** BFP1
use "$data/NonPublicFiles/BFP1_CQ_Clean_Data_with_checks_26May2020.dta", clear

	* 0. Drop obs with no ID 
		drop if facility_ID==. /*should be none*/

	* 1. KEEP only complete interviews 
		
		*keep if CEI_result==1
		keep if cei_result	==1		

	* 2. BASIC variables and manage missing/na recode
		
		gen country=this_country
		gen xsurvey="`survey'"	
		
		capture confirm variable phase
			if !_rc {
			}
			else{
				gen phase=substr(xsurvey, -1, 1)
			}		
		destring(phase), replace
		
		gen round=.
			replace round=6+phase if country=="Burkina"
			replace round=7+phase if country=="Kenya"
			replace round=5+phase if country=="Nigeria"
			
		gen interview_yr = substr(today, 1, 4)
		gen interview_mo = substr(today, 6, 2)
			destring(interview_yr), replace
			destring(interview_mo), replace
			
		gen interview_cmc 	= 12*(interview_yr - 1900) + interview_mo		
			
		lab var interview_mo "interview date, month"
		lab var interview_yr "interview date, year"
		lab var interview_cmc "interview date, CMC"

	* 2. RENAME 
	
		rename fp_reason_yn				visit_reason_fp
		rename whatgiven_today			fp_given_type
		rename hh_location_ladder		hh_wealth_selfrank
		rename pill_counsel 			prov_pill_couns 
		rename inj_counsel 				prov_inj_couns
		rename explain_method 			explain_mtd 
		rename explain_follow_up		explain_fu
		rename discuss_other_fp			disc_other_fp 
		rename discuss_switch			disc_fp_switch
		rename discuss_pro_con_delay 	disc_mtd_pro_con 
		rename howclear_fp_info 		fp_info_clarity 
		rename allow_question 			prov_alllow_que 
		rename understand_answer		understand_ans
		rename how_staff_treat 			staff_polite 
		rename satisfied_services_today service_satisfied 
		rename return_to_facility		return_hf
		rename time_wait_h				hf_wait_h
		rename time_wait_m				hf_wait_m
				
		#delimit;
		foreach var of varlist 
				fp_obtain_desired fp_obtain_desired_whynot
				prov_pill_couns prov_inj_couns
				explain_mtd - explain_fu
				disc_other_fp - disc_mtd_pro_con 
				fp_info_clarity prov_alllow_que understand_ans
				
				staff_polite service_satisfied refer_hf return_hf
				{;
				#delimit cr
			replace `var'=. if `var'<0
			}
	
	save "$data/CR_BFP1.dta", replace
	
	*/
	