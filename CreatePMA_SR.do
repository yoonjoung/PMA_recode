* This do file creates recode datafiles using public datasets
* each country specific "CreatedPMA_SR" should rund first, which takes care of country-specific variables and changes
		/*
		***** create RECODE file using public/raw data
		cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\"
		*do createPMA_HRPRIR.do
		do createPMA_SR_BurkinaFaso.do
		do createPMA_SR_CotedIvoire.do
		do createPMA_SR_DRC.do
		do createPMA_SR_Ethiopia.do     
		do createPMA_SR_India.do
		do createPMA_SR_Kenya.do
		do createPMA_SR_Niger.do
		do createPMA_SR_Nigeria.do
		do createPMA_SR_Uganda.do 
		===>do createPMA_SR.do /*this is a cross-survey program*/
		*/
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
global datalist " 
	BFR1 BFR2 BFR3 BFR4 BFR5 BFR6 BFP1 
	CIR1 CIR2
	CDKinshasaR3 CDKinshasaR4 CDKinshasaR5 CDKinshasaR6 CDKinshasaR7 CDKinshasaP1
	CDKongoCentralR4 CDKongoCentralR5 CDKongoCentralR6 CDKongoCentralR7 CDKongoCentralP1
	ETR2 ETR3 ETR4 ETR5 ETR6
	INRajasthanR1 INRajasthanR2 INRajasthanR3 INRajasthanR4  INRajasthanP1
	KER2 KER3 KER4 KER5 KER6 KER7 KEP1 
	NENiameyR1 NENiameyR2 NENiameyR3 NENiameyR4 NENiameyR5
	NER2 NER4 
	NGLagosR2 NGLagosR3 NGLagosR4 NGLagosR5 NGLagosP1 
	NGKanoR3  NGKanoR4  NGKanoR5 NGKanoP1  
	UGR2 UGR3 UGR4 UGR5 UGR6 UGP1
	";
	#delimit cr

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)
local todaystata=clock("`today'", "DMY")	

************************************************************************
* B. More variables
************************************************************************
	
/*
***** CHECK all surveys for their facility type classification 
foreach survey  in $datalist{
	use "$data/SR_`survey'.dta", clear	
	tab country xsurvey, m
	tab facility_type managing_authority, m
	codebook facility_type 
	}
	
foreach survey  in $datalist{
	use "$data/SR_`survey'.dta", clear	
	sum round facility_type
	}
	
foreach survey  in CIR1 CIR2 NER2 NER4 {
	use "$data/SR_`survey'.dta", clear	
	tab country xsurvey, m
	tab facility_type managing_authority, m
	codebook facility_type 
	}	

foreach survey  in CDKinshasaR7 CDKinshasaP1{
	use "$data/SR_`survey'.dta", clear	
	tab facility_type xsurvey, m
	}
	
foreach survey  in BFR5 BFR6 BFP1{
	use "$data/SR_`survey'.dta", clear	
	tab facility_type xsurvey, m
	}		
	
*/
	
	
set more off
foreach survey  in $datalist{
	use "$data/SR_`survey'.dta", clear	

	replace country=substr(xsurvey, 1,2)
	
			capture confirm variable ur
			if !_rc {
				drop ur
			}	
	
	* SDP characteristics 
	gen SDPall			= 1
	gen byte SDPpub		= managing_authority==1

	gen SDPpub12=0
	gen SDPlow=0
	gen SDPsecondary=0
	gen SDPprimary=0
	gen SDPpharmacy=0

		*BFP1 facility_code sucks!!!!! 
		gen facility_type_old_BFP1=facility_type if xsurvey=="BFP1"
			replace facility_type=6 if xsurvey=="BFP1" & facility_type_old_BFP1==1 /*clinic private*/
			replace facility_type=5 if xsurvey=="BFP1" & facility_type_old_BFP1==2 /*health center*/
			replace facility_type=7 if xsurvey=="BFP1" & facility_type_old_BFP1==3 /*health center prv*/
			replace facility_type=1 if xsurvey=="BFP1" & facility_type_old_BFP1==4 /*national_hospital*/
			replace facility_type=2 if xsurvey=="BFP1" & facility_type_old_BFP1==5 /*teaching_hospita*/
			replace facility_type=10 if xsurvey=="BFP1" & facility_type_old_BFP1==6 /*pharm_shop*/
			replace facility_type=9 if xsurvey=="BFP1" & facility_type_old_BFP1==7 /*pharmacy*/
			replace facility_type=3 if xsurvey=="BFP1" & facility_type_old_BFP1==8 /*regional_hospital */
			replace facility_type=4 if xsurvey=="BFP1" & facility_type_old_BFP1==9 /*surgery_center */
			replace facility_type=96 if xsurvey=="BFP1" & facility_type_old_BFP1==96 /*other*/

		replace SDPpub12	=1 if country=="BF" & managing_authority==1 & (facility_type>=4) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="BF" & (facility_type>=4) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="BF" & (facility_type>=4 & facility_type<=5 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="BF" & (facility_type>=6 & facility_type<=8 ) /*clinic_private, health_center_private*/	
		replace SDPpharmacy	=1 if country=="BF" & (facility_type>=9 & facility_type<=10 ) /*pharmacy or chemist*/
		
		replace SDPpub12	=1 if country=="CI" & managing_authority==1 & (facility_type>=5) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="CI" & (facility_type>=5) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="CI" & (facility_type>=5 & facility_type<=7 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="CI" & (facility_type>=8 & facility_type<=15 ) /*rural_dispensary and below*/
		replace SDPpharmacy	=1 if country=="CI" & (facility_type>=16 & facility_type<=17 ) /*pharmacy or chemist*/

		replace SDPpub12	=1 if country=="CD" & managing_authority==1 & (facility_type>=2) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="CD" & (facility_type>=2) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="CD" & (facility_type==2 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="CD" & (facility_type>=3 & facility_type<=4 ) /*Health clinic, Health post*/
		replace SDPpharmacy	=1 if country=="CD" & (facility_type>=5 & facility_type<=6 ) /*pharmacy or chemist*/	
			
			*temporary until PMA fixes pharmacy code
			replace SDPpharmacy	=1 if xsurvey=="CDKinshasaP1" & (facility_type==96) /*pharmacy or chemist*/	
			replace SDPpharmacy	=1 if xsurvey=="CDKongoCentralP1" & (facility_type==96) /*pharmacy or chemist*/	
	
		replace SDPpub12	=1 if country=="ET" & managing_authority==1 & (facility_type>=2) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="ET" & (facility_type>=2) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="ET" & (facility_type==2 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="ET" & (facility_type>=3 & facility_type<=4 ) /*Health post, Health clinic*/
		replace SDPpharmacy	=1 if country=="ET" & (facility_type>=5 & facility_type<=6 ) /*pharmacy or chemist*/
		
		replace SDPpub12	=1 if country=="IN" & managing_authority==1 & (facility_type>=2) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="IN" & (facility_type>=2) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="IN" & (facility_type>=2 & facility_type<=3 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="IN" & (facility_type>=4 & facility_type<=6 ) /*community_center_PHC, dispensary, subcenter*/
		replace SDPpharmacy	=1 if country=="IN" & (facility_type==7 ) /*pharmacy or chemist*/
	
		replace SDPpub12	=1 if country=="KE" & managing_authority==1 & (facility_type>=2) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="KE" & (facility_type>=2) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="KE" & (facility_type==2 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="KE" & (facility_type>=3 & facility_type<=4 ) /*health_clinic, dispensary*/
		replace SDPpharmacy	=1 if country=="KE" & (facility_type==5 ) /*pharmacy or chemist*/
		
		replace SDPpub12	=1 if country=="NE" & managing_authority==1 & (facility_type>=4) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="NE" & (facility_type>=4) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="NE" & (facility_type>=4 & facility_type<=6 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="NE" & (facility_type>=7 & facility_type<=11 ) /*health hut,  private_room, private_practice*/		
		replace SDPpharmacy	=1 if country=="NE" & (facility_type>=12 & facility_type<=14 ) /*pharmacy or chemist*/		
				
		replace SDPpub12	=1 if country=="NG" & managing_authority==1 & (facility_type>=2) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="NG" & (facility_type>=2) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="NG" & (facility_type>=2 & facility_type<=3 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="NG" & (facility_type>=4 & facility_type<=6 ) /*Health Clinic/Post*/
		replace SDPpharmacy	=1 if country=="NG" & (facility_type>=7 & facility_type<=8 ) /*pharmacy or chemist*/
		
		replace SDPpub12	=1 if country=="UG" & managing_authority==1 & (facility_type>=3) /*public, excludnig hospitals*/
		replace SDPlow		=1 if country=="UG" & (facility_type>=3) /*excludnig hospitals*/
		replace SDPsecondary=1 if country=="UG" & (facility_type==3 ) /*SECONDARY health centers */	
		replace SDPprimary	=1 if country=="UG" & (facility_type>=4 & facility_type<=5 ) /*health_center_2, health_clinic*/
		replace SDPpharmacy	=1 if country=="UG" & (facility_type>=6 & facility_type<=7 ) /*pharmacy or chemist*/
		 
	save "$data/SR_`survey'.dta", replace
}

*************************************************************************************************
* B.3 Gen more availablity metrics
*************************************************************************************************
/*
set more off
foreach survey  in $datalist{
	use "$data/SR_`survey'.dta", clear	
	sum total_methods_offered total_methods_available total_methods_noso
	}
*/


set more off
foreach survey  in $datalist{
	use "$data/SR_`survey'.dta", clear	

		* 3 or 5 methods per FP2020 indicators 11a & 11b*
		gen offer3= total_methods_offered>=3
		gen offer5= total_methods_offered>=5	
		
		gen curav3= total_methods_available>=3
		gen curav5= total_methods_available>=5
	
		gen noso3= total_methods_noso>=3
		gen noso5= total_methods_noso>=5		
		
		foreach x in offer curav noso{
		gen byte fp2020_`x' = (`x'3==1 & SDPlow==1) | (`x'5==1 & SDPlow==0) 
			replace fp2020_`x' =0 if (`x'5==0 & SDPsecondary==1)
			replace fp2020_`x' =1 if (`x'5==1 & SDPsecondary==1)
			}
				
		* excluding IUD in primary SDPs or pharmacy etc.*
		gen byte essential_offer = essential5_offer 
		gen byte essential_curav = essential5_curav
		gen byte essential_noso	 = essential5_noso  			
		gen byte essential_ready = essential5_ready	
		gen byte essential_rnoso = essential5_rnoso
		
				foreach var of varlist 	offer_stockout_implants offer_stockout_injectables offer_stockout_pill offer_stockout_male_condoms{
					gen byte temp_`var' = `var'<=3	
					}
				egen tempsum=rowtotal(temp_*)		
			replace  essential_offer = 1 if (SDPprimary==1 & tempsum==4) | (SDPpharmacy==1 & tempsum==4 )
			replace  essential_offer = 1 if((SDPprimary==1 & tempsum==3) | (SDPpharmacy==1 & tempsum==3 ))& country=="IN" 
				drop temp*
				
				foreach var of varlist 	offer_stockout_implants offer_stockout_injectables offer_stockout_pill offer_stockout_male_condoms{
					gen byte temp_`var' = `var'<=2
					}
				egen tempsum=rowtotal(temp_*)		
			replace  essential_curav = 1 if (SDPprimary==1 & tempsum==4) | (SDPpharmacy==1 & tempsum==4 )
			replace  essential_offer = 1 if((SDPprimary==1 & tempsum==3) | (SDPpharmacy==1 & tempsum==3 ))& country=="IN" 
				drop temp*
				
				foreach var of varlist 	offer_stockout_implants offer_stockout_injectables offer_stockout_pill offer_stockout_male_condoms{
					gen byte temp_`var' = `var'<=2
					}
				egen tempsum=rowtotal(temp_*)		
			replace  essential_noso = 1 if (SDPprimary==1 & tempsum==4) | (SDPpharmacy==1 & tempsum==4 )
			replace  essential_offer = 1 if((SDPprimary==1 & tempsum==3) | (SDPpharmacy==1 & tempsum==3 ))& country=="IN" 
			replace  essential_ready = 1 if (SDPprimary==1 & tempsum==4 &  ready_implant==1 ) | (SDPpharmacy==1 & tempsum==4 &  ready_implant==1 )
			replace  essential_ready = 1 if((SDPprimary==1 & tempsum==3 &  ready_implant==1 ) | (SDPpharmacy==1 & tempsum==3 &  ready_implant==1 ))& country=="IN" 
				drop temp*				

				foreach var of varlist 	offer_stockout_implants offer_stockout_injectables offer_stockout_pill offer_stockout_male_condoms{
					gen byte temp_`var' = `var'<=1
					}
				egen tempsum=rowtotal(temp_*)		
			replace  essential_rnoso = 1 if (SDPprimary==1 & tempsum==4 &  ready_implant==1 ) | (SDPpharmacy==1 & tempsum==4 &  ready_implant==1 )
			replace  essential_ready = 1 if((SDPprimary==1 & tempsum==3 &  ready_implant==1 ) | (SDPpharmacy==1 & tempsum==3 &  ready_implant==1 ))& country=="IN" 
				drop temp*				
			
	save "$data/SR_`survey'.dta", replace
}

COMPLETED
