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

* define data list for recode 
/*Uganda SDP requested 2/21/2020 */
#delimit;
global datalist " 
	UGR2 UGR3 UGR4 UGR5 UGR6 
	";
	#delimit cr
	
#delimit;
global datalistminusone " 
	UGR3 UGR4 UGR5 UGR6 
	";
	#delimit cr	

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)
local todaystata=clock("`today'", "DMY")	
	
************************************************************************
* B. READ in non-public data if any 
************************************************************************

*N/A

************************************************************************
* C. PREP for DATA PROCESSING: check any CHANGES in questionnaire
************************************************************************

* CHANGES in basic facility level & type?  	
	foreach survey in $datalist{
	use "$data/rawSDP/SDP_`survey'.dta", clear	
		sum round 
		codebook managing_authority 
	}
	
	foreach survey in $datalist{
	use "$data/rawSDP/SDP_`survey'.dta", clear	
		sum round 
		codebook facility_type
	}	
	
* CHANGES IN key variables ACROSS ROUNDS? 
*	This can be just name change or actual changes in questionnaire
*	pay extra attention to PILLS & INJECTABLES  

	use "$data/rawSDP/SDP_UGR2.dta", clear		
	foreach survey in $datalistminusone{
		append using "$data/rawSDP/SDP_`survey'.dta", force
	}	

		*Check don't know and N/A coding*/	
		sum provided_* 
		sum stock_* 
		sum stockout_3mo_*

		*rounds when JUST "pills" was asked*/
		tab round stock_pills, m 
	
		*DATALIST1: rounds when JUST "injectables" was asked*/
		tab round stock_injectables, m 
		
		*DATALIST2: rounds when "sayana_press vs. depo_provera" was asked*/
		tab round stock_sayana_press, m 
		
		*DATALIST3: rounds when "injectable_sp vs. injectable_dp" was asked*/
		*tab round stock_injectable_sp, m /*NONE yet*/

* CHANGES IN readiness variables?  

	foreach survey  in $datalist{
	use "$data/rawSDP/SDP_`survey'.dta", clear	
		sum round implant_insert implant_remove iud_insert iud_remove
	}

	foreach survey  in $datalist{
	use "$data/rawSDP/SDP_`survey'.dta", clear	
		sum round iud_forceps iud_speculums iud_tenaculum 
		sum round implant_gloves implant_antiseptic implant_sterile_gauze implant_anesthetic implant_sealed_pack implant_blade
	}
	
		
************************************************************************
* D. DEFINE MACROS - Uganda	 
************************************************************************
*	this becomes complicated when different countries are on different schedule 
*	For now, only Uganda 

	*Country code
	local CC "UG"
	*First round of data 
	local first_round 2
	*Last round of data
	local last_round 6
	*First round of PMA2 
	local first_round_pma2 7 
	
	*Last round where JUST "injectables" was asked
	local last_round_inj 4
	*Three sets of datalist based on injectables variables
	global datalist1 "UGR2 UGR3 UGR4"  
	global datalist2 "UGR5 UGR6"
	global datalist3 ""/*NONE yet*/
	
	*Non-permanent modern methods (used for threshold: 
	*	create injectables even if ask about depo & sayana press separately
	*	check pill type - country specific
	*	check injectable month type - country specific 
	local methods "iud implants injectables sayana_press depo_provera pills male_condoms female_condoms ec"
	local methodsminusiud "implants injectables sayana_press depo_provera pills male_condoms female_condoms ec"

*********************************************************
***** create RECODE SDP variables: NOTHING country specific below.  
*********************************************************	
	
	foreach survey in $datalist{
		use "$data/rawSDP/SDP_`survey'.dta", clear
	
		gen xsurvey="`survey'"		
	
	* 0. Drop obs with no ID 
	
		drop if facility_ID==.
	
	* 0.5 Drop duplicate observations 
	
		sort facility_ID
        quietly by facility_ID:  gen dup = cond(_N==1,0,_n)
        tabulate dup xsurvey, m

	* 1. KEEP only complete interviews 
		
		keep if SDP_result==1

	* 2. BASIC variables and manage missing/na recode
		
		*gen xsurvey="`survey'"		
		
		gen byte pma2=round>=`first_round_pma2'

		gen sector=.
		replace sector=0 if managing_authority==1 
		replace sector=1 if managing_authority!=1 & managing_authority!=.
		label define sector_list 0 Public 1 Private
		label val sector sector_list

		gen temp = dofc(todaySIF)
		format %td temp
			gen interview_mo = month(temp)
			gen interview_yr = year(temp)
			gen interview_cmc 	= 12*(interview_yr - 1900) + interview_mo		
			drop temp	
		lab var interview_mo "interview date, month"
		lab var interview_yr "interview date, year"
		lab var interview_cmc "interview date, CMC"

		foreach x of varlist provided_* stock_* stockout_3mo_*{
			replace `x'=. if `x'<0
			}
	
		save "$data/SR_`survey'.dta", replace
		}
		
	* 3. PREP variables for chaning methods names/coding 	
	* 		DEAL with different injectable names across surveys 
	
	foreach survey in $datalist1{
		use "$data/SR_`survey'.dta", clear

			global injlist "depo_provera sayana_press"
			foreach x in $injlist{	
				gen provided_`x'=.
				gen stock_`x'=.
				gen stockout_3mo_`x'=.
			}

		save "$data/SR_`survey'.dta", replace
		}
		
	foreach survey in $datalist2{
		use "$data/SR_`survey'.dta", clear

			foreach x in injectables{	
				gen provided_`x'=.
				gen stock_`x'=.
				gen stockout_3mo_`x'=.
			}
			
		save "$data/SR_`survey'.dta", replace
		}
		
	foreach survey in $datalist3{
		use "$data/SR_`survey'.dta", clear

			foreach x in injectables{	
				gen provided_`x'=.
				gen stock_`x'=.
				gen stockout_3mo_`x'=.
			}
			
			foreach x in depo_provera{	
			foreach y in injectable_dp{
				gen provided_`x'	=provided_`y'
				gen stock_`x'		=stock_`y'
				gen stockout_3mo_`x'=stockout_3mo_`y'
			}
			}

			foreach x in sayana_press{	
			foreach y in injectable_sp{
				gen provided_`x'	=provided_`y'
				gen stock_`x'		=stock_`y'
				gen stockout_3mo_`x'=stockout_3mo_`y'
			}
			}
			
		save "$data/SR_`survey'.dta", replace
		}
	
	foreach survey in $datalist{
		use "$data/SR_`survey'.dta", clear

			egen sdsayana=sd(stock_sayana)
			
			* PROVIDED
			gen provided_sayanadepo=.
				replace provided_sayanadepo=0 if provided_depo_provera==0 | provided_sayana_press==0
				replace provided_sayanadepo=1 if provided_depo_provera==1 | provided_sayana_press==1
				
			
				replace provided_injectables = provided_sayanadepo if round>`last_round_inj' /*when both sayana and depo have non-missing values*/		
				replace provided_injectables = provided_depo if round>`last_round_inj' & sdsayana==0 /*when sayana is universally missing*/

			* STOCK 
			gen stock_sayanadepo=.
				replace stock_sayanadepo=1 if stock_depo_provera==1 | stock_sayana_press==1
				replace stock_sayanadepo=2 if stock_depo_provera>=2 & stock_sayana_press>=2
				replace stock_sayanadepo=3 if stock_depo_provera>=3 & stock_sayana_press>=3
				replace stock_sayanadepo=. if stock_depo_provera==. & stock_sayana_press==.

				replace stock_injectables = stock_sayanadepo if round>`last_round_inj' /*when both sayana and depo have non-missing values*/
				replace stock_injectables = stock_depo if round>`last_round_inj' & sdsayana==0	/*when both sayana is universally missing*/

			* 3-MO STOCKOUT
			gen stockout_3mo_sayanadepo=.
				replace stockout_3mo_sayanadepo=0 if stockout_3mo_depo_provera==0 | stockout_3mo_sayana_press==0
				replace stockout_3mo_sayanadepo=1 if stockout_3mo_depo_provera>=1 & stockout_3mo_sayana_press>=1
				replace stockout_3mo_sayanadepo=. if stockout_3mo_depo_provera==. & stockout_3mo_sayana_press==.
			
				replace stockout_3mo_injectables = stockout_3mo_sayanadepo if round>`last_round_inj' /*when both sayana and depo have non-missing values*/		
				replace stockout_3mo_injectables = stockout_3mo_depo if round>`last_round_inj' & sdsayana==0 /*when both sayana is universally missing*/
			
	* 4. KEY variable: 4-category availability variable: 
	*		based on BOTH current and 3=mo data
	
		label define offer_stockout_lab 1 "In stock" 2 "In stock, but stockout last 3 months" 3 "Out of stock" 4 "Don't offer the method"

		foreach x in `methods'{
		capture noisily gen offer_stockout_`x'=.
			capture noisily replace offer_stockout_`x'=4 if fp_offer==1
			capture noisily replace offer_stockout_`x'=1 if fp_offer==1 & provided_`x'==1 & (stock_`x'==1 | stock_`x'==2) /*observed OR unobserved*/
			capture noisily replace offer_stockout_`x'=2 if fp_offer==1 & provided_`x'==1 & (stock_`x'==1 | stock_`x'==2) & stockout_3mo_`x'==1
			capture noisily replace offer_stockout_`x'=3 if fp_offer==1 & provided_`x'==1 & (stock_`x'==3)
			capture noisily replace offer_stockout_`x'=4 if fp_offer==1 & provided_`x'==0 
		capture label var offer_stockout_`x' "4-category availability of `x' among those that offer FP"
		capture label val offer_stockout_`x' offer_stockout_lab
		}
				

	* 5. KEY variable: TOTAL number of available methods: 
	* 		only based on current data
	* 		But, counting male or female sterilization
		
		label define yes_no 0 "No" 1 "Yes"

		foreach x in `methods' {
			gen available_`x'=0
			replace available_`x'=1 	if offer_stockout_`x'<=2
			label variable available_`x' "`x' available at facility on day of interview"
			tab available_`x'
			}	
			
		foreach x in `methods' {
			gen offer_`x'=0
			replace offer_`x'=1 		if offer_stockout_`x'<=3
			label variable offer_`x' "`x' offered"
			tab offer_`x'
			}				
			
		foreach x in `methods' {
			gen noso_`x'=0
			replace noso_`x'=1 			if offer_stockout_`x'<=1
			label variable noso_`x' "`x' available without stock-out"
			tab offer_`x'
			}							
			
		* Create variable that represents the total number of modern methods available on day of interview
		gen total_methods_available=0
		foreach x in `methods'{
		replace total_methods_available=total_methods_available + available_`x'
		}
				
		* Create variable that represents the total number of modern methods offered on day of interview
		gen total_methods_offered=0
		foreach x in `methods'{
		replace total_methods_offered=total_methods_offered + offer_`x'
		}
		
		* Create variable that represents the total number of modern methods available on day of interview without stockout
		gen total_methods_noso=0
		foreach x in `methods'{
		replace total_methods_noso=total_methods_noso + noso_`x'
		}		
		
		* revise total_methods_available/offered/noso, incorporating sterilization
		replace total_methods_available=total_methods_available + provided_female_ster if provided_female_ster~=.
		replace total_methods_available=total_methods_available + provided_male_ster if provided_male_ster~=.
		label variable total_methods_available "Total number of modern methods available on day of interview"

		replace total_methods_offered=total_methods_offered + provided_female_ster if provided_female_ster~=.
		replace total_methods_offered=total_methods_offered + provided_male_ster if provided_male_ster~=.
		label variable total_methods_offered "Total number of modern methods offered"
		
		replace total_methods_noso=total_methods_noso + provided_female_ster if provided_female_ster~=.
		replace total_methods_noso=total_methods_noso + provided_male_ster if provided_male_ster~=.
		label variable total_methods_noso "Total number of modern methods available on day of interview without stock out"

		
	* 6. KEY variable: readiness for IUD and implants 
	* 		stock, HR, and supply/equipment 
		
		foreach x of varlist stock_iud stock_implant {
		gen byte av`x'=`x'==1
		lab var av`x' "`x' In-stock and observed, among all facilities"	
		}

		gen byte hr_iud		= iud_insert==1 & iud_remove==1		
		gen byte hr_implant = implant_insert==1 & implant_remove==1

		egen sup_iud 		= rowtotal(iud_forceps iud_speculums iud_tenaculum )
			replace sup_iud	= 0 if sup_iud<=2
			replace sup_iud = 1 if sup_iud==3
		egen sup_implant	= rowtotal(implant_gloves implant_antiseptic implant_sterile_gauze implant_anesthetic implant_sealed_pack implant_blade)
			replace sup_implant	= 0 if sup_implant<=5
			replace sup_implant = 1 if sup_implant==6
			
		gen byte ready_iud 	= avstock_iud ==1 & hr_iud==1 & sup_iud==1	
		gen byte ready_implant = avstock_implant ==1 & hr_implant==1 & sup_implant==1
		
		lab var hr_iud 		"personnel for insert/removal"
		lab var sup_iud 	"supplies for insert/removal"	
		lab var ready_iud 	"personnel AND supplies AND stock" 
		lab var hr_implant 		"personnel for insert/removal"
		lab var sup_implant 	"supplies for insert/removal"	
		lab var ready_implant 	"personnel AND supplies AND stock" 

	* 7. KEY variable: essential methods - specific set of methods 
	* Essential VERSION 1. based on service availability 
		
		capture drop temp*
		
		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=3
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5_offer=tempsum==5
			drop temp*
		label var essential5_offer "Facility offering 5 essential methods: IUD, implants, injectables, pills, AND male condom"
		label val essential5_offer yes_no
		
		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=3
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5ec_offer=tempsum==6
			drop temp*
		label var essential5ec_offer "Facility offering 5 essential methods + EC: IUD, implants, injectables, pills, male condom, AND EC"
		label val essential5ec_offer yes_no		
		
		gen byte temp_longact =offer_stockout_iud<=3 | offer_stockout_implants<=3 
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr		
		gen byte temp_`var' = `var'<=3
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4_offer=tempsum==4
			drop temp*
		label var essential4_offer "Facility offering 4 essential methods: IUD or implants, injectables, pills, AND male condom"
		label val essential4_offer yes_no
		
		gen byte temp_longact =offer_stockout_iud<=3 | offer_stockout_implants<=3 
		#delimit; 
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=3
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4ec_offer=tempsum==5
			drop temp*
		label var essential4ec_offer "Facility offering 4 essential methods + EC: IUD or implants, injectables, pills, male condom, AND EC"
		label val essential4ec_offer yes_no

	* Essential VERSION 2. based on current availability of methods 
		
		capture drop temp*
		
		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5_curav=tempsum==5
			drop temp*
		label var essential5_curav "Facility currently with 5 essential methods: IUD, implants, injectables, pills, AND male condom"
		label val essential5_curav yes_no

		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec { ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5ec_curav=tempsum==6
			drop temp*
		label var essential5ec_curav "Facility currently with 5 essential methods + EC: IUD, implants, injectables, pills, AND male condom"
		label val essential5ec_curav yes_no
		
		gen byte temp_longact =offer_stockout_iud<=2 | offer_stockout_implants<=2 
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr		
		gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4_curav=tempsum==4
			drop temp*
		label var essential4_curav "Facility currently with 4 essential methods: IUD or implants, injectables, pills, AND male condom"
		label val essential4_curav yes_no
		
		gen byte temp_longact =offer_stockout_iud<=2 | offer_stockout_implants<=2 
		#delimit; 
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4ec_curav=tempsum==5
			drop temp*
		label var essential4ec_curav "Facility currently with 4 essential methods + EC: IUD or implants, injectables, pills, male condom, AND EC"
		label val essential4ec_curav yes_no
		
	* Essential VERSION 3. based on current availability and no 3-mo stockout of methods 
		
		capture drop temp*
		
		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=1
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5_noso=tempsum==5
			drop temp*
		label var essential5_noso "Facility currently with 5 essential methods, no 3-mo stockout: IUD, implants, injectables, pills, AND male condom"
		label val essential5_noso yes_no

		#delimit;
		foreach var of varlist 	offer_stockout_iud 
								offer_stockout_implants 
								offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec { ;
								#delimit cr
			gen byte temp_`var' = `var'<=1
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5ec_noso=tempsum==6
			drop temp*
		label var essential5ec_noso "Facility currently with 5 essential methods + EC, no 3-mo stockout: IUD, implants, injectables, pills, AND male condom"
		label val essential5ec_noso yes_no
		
		gen byte temp_longact =offer_stockout_iud<=1 | offer_stockout_implants<=1 
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr		
		gen byte temp_`var' = `var'<=1
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4_noso=tempsum==4
			drop temp*
		label var essential4_noso "Facility currently with 4 essential methods, no 3-mo stockout: IUD or implants, injectables, pills, AND male condom"
		label val essential4_noso yes_no
		
		gen byte temp_longact =offer_stockout_iud<=1 | offer_stockout_implants<=1 
		#delimit; 
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=1
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4ec_noso=tempsum==5
			drop temp*
		label var essential4ec_noso "Facility currently with 4 essential methods + EC, no 3-mo stockout: IUD or implants, injectables, pills, male condom, AND EC"
		label val essential4ec_noso yes_no		
		
	* Essential VERSION 4. based on current availability and readiness 
		
		capture drop temp*
		
		gen byte temp_iud = ready_iud==1 
		gen byte temp_implants = ready_implant==1
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5_ready=tempsum==5
			drop temp*
		label var essential5_ready "Facility currently with 5 essential methods, plus ready to provide IUD and implants: IUD, implants, injectables, pills, AND male condom"
		label val essential5_ready yes_no

		gen byte temp_iud = ready_iud==1 
		gen byte temp_implants = ready_implant==1		
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec { ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential5ec_ready=tempsum==6
			drop temp*
		label var essential5ec_ready "Facility currently with 5 essential methods + EC, plus ready to provide IUD and implants: IUD, implants, injectables, pills, AND male condom"
		label val essential5ec_ready yes_no
		
		gen byte temp_longact =ready_iud==1 | ready_implant==1
		#delimit;
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms{ ;
								#delimit cr		
		gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4_ready=tempsum==4
			drop temp*
		label var essential4_ready "Facility currently with 4 essential methods, plus ready to provide IUD OR implants: IUD or implants, injectables, pills, AND male condom"
		label val essential4_ready yes_no
		
		gen byte temp_longact =ready_iud==1 | ready_implant==1
		#delimit; 
		foreach var of varlist 	offer_stockout_injectables 
								offer_stockout_pill 
								offer_stockout_male_condoms
								offer_stockout_ec{ ;
								#delimit cr
			gen byte temp_`var' = `var'<=2
			}
			egen tempsum=rowtotal(temp_*)
			tab tempsum
		gen byte essential4ec_ready=tempsum==5
			drop temp*
		label var essential4ec_ready "Facility currently with 4 essential methods + EC, plus ready to provide IUD OR implants: IUD or implants, injectables, pills, male condom, AND EC"
		label val essential4ec_ready yes_no		

	* Essential VERSION 5. based on readiness AND no stockout 
			
		capture drop temp*
	
		gen essential5_rnoso 	= essential5_ready==1 & essential5_noso==1
		gen essential5ec_rnoso 	= essential5ec_ready==1 & essential5ec_noso==1
		gen essential4_rnoso 	= essential4_ready==1 & essential4_noso==1
		gen essential4ec_rnoso 	= essential4ec_ready==1 & essential4ec_noso==1
	
	save "$data/SR_`survey'.dta", replace
	}		

*COMPLETED
