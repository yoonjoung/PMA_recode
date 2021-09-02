* This do file creates recode datafiles using public datasets + non-public datasets (Section B)
clear 
clear matrix
clear mata
set more off
set mem 300m
set maxvar 9000

* A. SETTING 
* B. READ in non-public data if any : KER8, BFR7, NGLagosR6, NGKanoR6  
* C. extract only Kano & Lagos from Nigeria public datasets; same for Kinshasa and KongoCentral from DRC; and Niger surveys
* D. create HR, PR, and IR

************************************************************************
* A. SETTING 
************************************************************************
* run the python file with the downloaded public files - 
* i.e., save public files with specific names used in "surveylist" below 

global data "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\"
cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\"

* define data list for recode 
/*
cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\rawHHQFQ\"
dir 
*/

* rename India P1 data to Rajasthan

use "$data/rawHHQFQ/HHQFQ_INP1.dta", clear 
save "$data/rawHHQFQ/HHQFQ_INRajasthanP1.dta", replace  


#delimit;
global surveylist " 
	BFR1 BFR2 BFR3 BFR4 BFR5 BFR6 BFP1
	CIR1 CIR2
	CDKinshasaR1 CDKinshasaR2 CDKinshasaR3 CDKinshasaR4 CDKinshasaR5 CDKinshasaR6 CDKinshasaR7 CDKinshasaP1
	CDKongoCentralR4 CDKongoCentralR5 CDKongoCentralR6 CDKongoCentralR7 CDKongoCentralP1
	INRajasthanR1 INRajasthanR2 INRajasthanR3 INRajasthanR4 INRajasthanP1
	KER2 KER3 KER4 KER5	KER6 KER7 KEP1
	NENiameyR1 NENiameyR2 NENiameyR3 NENiameyR4 NENiameyR5
	NER2 NER4 
	NGLagosR2 NGLagosR3 NGLagosR4 NGLagosR5 NGLagosP1 
	NGKanoR3  NGKanoR4  NGKanoR5  NGKanoP1 
	UGR1 UGR2 UGR3 UGR4 UGR5 UGR6 UGP1 
	ETR2 ETR3 ETR4 ETR5	ETR6 
	";
	#delimit cr	

#delimit;
global surveylistgen2 " 	
	BFP1 CDKinshasaP1 CDKongoCentralP1 INRajasthanP1 KEP1 NGLagosP1 NGKanop1 UGP1	
	";
	#delimit cr	
************************************************************************
* B. READ in non-public data if any : KER8, BFR7, NGLagosR6, & NGKanoR6 
************************************************************************
/*
cd "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\NonPublicFiles\"
dir
*/

/***** KER8	
use "$data/NonPublicFiles/KEP1_WealthWeightAll_26Jun2020.dta", clear

		gen round=8
		egen EA_ID=group(EA)
		egen memberID=group(member_number) 
		
		gen wealthquintile=wealth_Kenya
		
	save "$data/rawHHQFQ/HHQFQ_KER8.dta", replace
	*/
	
/***** BFR7
use "$data/NonPublicFiles/BFP1_WealthWeightAll_17Apr2020.dta", clear
	
		gen round=7
		egen EA_ID=group(EA)
		egen memberID=group(member_number) 

	save "$data/rawHHQFQ/HHQFQ_BFR7.dta", replace
	*/

/***** NGLagosR6
use "$data/NonPublicFiles/NGP1_Lagos_WealthWeightAll_12May2020.dta", clear

		sum FQweight*

		gen round=6
		egen EA_ID=group(EA)
		egen memberID=group(member_number) 
		
		gen HHweight=HHweight_Lagos
		gen FQweight=FQweight_Lagos
	save "$data/rawHHQFQ/HHQFQ_NGLagosR6.dta", replace
	
***** NGKanoR6
use "$data/NonPublicFiles/NGP1_Kano_WealthWeightAll_17Jun2020.dta", clear

		sum FQweight*

		gen round=6
		egen EA_ID=group(EA)
		egen memberID=group(member_number) 
		
		gen HHweight=HHweight_Kano
		gen FQweight=FQweight_Kano
	save "$data/rawHHQFQ/HHQFQ_NGKanoR6.dta", replace	
*/
	
/*
log using NigeriaDataCheck.log, replace
use "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\NonPublicFiles\NGP1_Kano_WealthWeightAll_7Apr2020.dta", clear
	tab level1, m
	lookfor weight
	d HHweight* FQweight*
	sum HHweight* FQweight*
use "C:\Users\YoonJoung Choi\Dropbox\0 Data\PMA\NonPublicFiles\NGP1_Lagos_WealthWeightAll_7Apr2020.dta"
	tab level1, m
	lookfor weight
	d HHweight* FQweight*
	sum HHweight* FQweight*
log close
*/	
	
*********************************************************
* C.1. extract only Kano & Lagos from Nigeria
*********************************************************		
#delimit;
use "$data/rawHHQFQ/HHQFQ_NGR2_Lagos.dta", clear ; 		keep if state==2 ; save "$data/rawHHQFQ/HHQFQ_NGLagosR2.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGR3_National.dta", clear ;	keep if state==2 ; gen HHweight=HHweight_Lagos ; gen FQweight=FQweight_Lagos ; gen wealthquintile=wealthquintile_Lagos ; save "$data/rawHHQFQ/HHQFQ_NGLagosR3.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGR4_National.dta", clear ;	keep if state==2 ; gen HHweight=HHweight_Lagos ; gen FQweight=FQweight_Lagos ; gen wealthquintile=wealthquintile_Lagos ; save "$data/rawHHQFQ/HHQFQ_NGLagosR4.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGR5_National.dta", clear ;	keep if state==2 ; gen HHweight=HHweight_Lagos ; gen FQweight=FQweight_Lagos ; gen wealthquintile=wealthquintile_Lagos ; save "$data/rawHHQFQ/HHQFQ_NGLagosR5.dta", replace ; 	
	
use "$data/rawHHQFQ/HHQFQ_NGR3_National.dta", clear ;	keep if state==4 ; gen HHweight=HHweight_Kano ; gen FQweight=FQweight_Kano ; gen wealthquintile=wealthquintile_Kano ; save "$data/rawHHQFQ/HHQFQ_NGKanoR3.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGR4_National.dta", clear ;	keep if state==4 ; gen HHweight=HHweight_Kano ; gen FQweight=FQweight_Kano ; gen wealthquintile=wealthquintile_Kano ; save "$data/rawHHQFQ/HHQFQ_NGKanoR4.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGR5_National.dta", clear ;	keep if state==4 ; gen HHweight=HHweight_Kano ; gen FQweight=FQweight_Kano ; gen wealthquintile=wealthquintile_Kano ; save "$data/rawHHQFQ/HHQFQ_NGKanoR5.dta", replace ;;
#delimit cr	

#delimit;
use "$data/rawHHQFQ/HHQFQ_NGP1_Kano", clear ; save "$data/rawHHQFQ/HHQFQ_NGKanoP1.dta", replace ; 
use "$data/rawHHQFQ/HHQFQ_NGP1_Lagos", clear ; save "$data/rawHHQFQ/HHQFQ_NGLagosP1.dta", replace ; 
#delimit cr	

#delimit;
global NGsurveylist " 
	NGLagosR2 NGLagosR3 NGLagosR4 NGLagosR5 NGLagosP1 
	NGKanoR3  NGKanoR4  NGKanoR5 NGKanoP1 
	";
	#delimit cr	
	
foreach survey  in $NGsurveylist{
	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	rename Cluster_ID EA_ID
	
	capture confirm variable strata
		if !_rc {
		}
		else{
			gen strata=state
		}
	save "$data/rawHHQFQ/HHQFQ_`survey'.dta", replace
}

/*
foreach survey  in $NGsurveylist{
	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	tab state 
	codebook EA_ID 
}

*/


*********************************************************
* C.2. rename DRC surveys 
*********************************************************	
#delimit;
use "$data/rawHHQFQ/HHQFQ_CDR1_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR1.dta", replace ;		
use "$data/rawHHQFQ/HHQFQ_CDR2_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR2.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR3_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR3.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR4_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR4.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR5_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR5.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR6_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR6.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR7_Kinshasa.dta", clear ; 		save "$data/rawHHQFQ/HHQFQ_CDKinshasaR7.dta", replace ;

use "$data/rawHHQFQ/HHQFQ_CDR4_KongoCentral.dta", clear ; 	save "$data/rawHHQFQ/HHQFQ_CDKongoCentralR4.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR5_KongoCentral.dta", clear ; 	save "$data/rawHHQFQ/HHQFQ_CDKongoCentralR5.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR6_KongoCentral.dta", clear ; 	save "$data/rawHHQFQ/HHQFQ_CDKongoCentralR6.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_CDR7_KongoCentral.dta", clear ; 	save "$data/rawHHQFQ/HHQFQ_CDKongoCentralR7.dta", replace ;

#delimit cr	

#delimit;
global DRCsurveylist " 
	CDKinshasaR1 CDKinshasaR2 CDKinshasaR3 CDKinshasaR4 CDKinshasaR5 CDKinshasaR6 CDKinshasaR7 CDKinshasaP1
	CDKongoCentralR4 CDKongoCentralR5 CDKongoCentralR6 CDKongoCentralR7 CDKongoCentralP1
	";
	#delimit cr	

foreach survey  in $DRCsurveylist{
	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	lookfor strata
}		
	
*********************************************************
* C.3. rename Niger and Niamey surveys 
*********************************************************	
#delimit;
use "$data/rawHHQFQ/HHQFQ_NER1_Niamey.dta", clear 	; keep if region==1 ; save "$data/rawHHQFQ/HHQFQ_NENiameyR1.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_NER2_National.dta", clear ; keep if region==1 ; save "$data/rawHHQFQ/HHQFQ_NENiameyR2.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_NER3_Niamey.dta", clear 	; keep if region==1 ; save "$data/rawHHQFQ/HHQFQ_NENiameyR3.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_NER4_National.dta", clear ; keep if region==1 ; save "$data/rawHHQFQ/HHQFQ_NENiameyR4.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_NER5.dta", clear 			; keep if region==1 ; save "$data/rawHHQFQ/HHQFQ_NENiameyR5.dta", replace ;

use "$data/rawHHQFQ/HHQFQ_NER2_National.dta", clear	; save "$data/rawHHQFQ/HHQFQ_NER2.dta", replace ;
use "$data/rawHHQFQ/HHQFQ_NER4_National.dta", clear	; save "$data/rawHHQFQ/HHQFQ_NER4.dta", replace ;
#delimit cr	

#delimit;
global NEsurveylist " 
	NENiameyR1 NENiameyR2 NENiameyR3 NENiameyR4 NENiameyR5
	NER2 NER4 
	";
	#delimit cr	
  
foreach survey  in $NEsurveylist{
	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	lookfor wealth 
}	

*********************************************************
* D. create HR, PR, and IR
*********************************************************	
/*
set more off
foreach survey  in $surveylist{

	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	tab country round
	*codebook birth_ev
	codebook metainstanceID eligible gender age
		gen byte xeligible=gender==2 & (age>=15 & age<=49)
		egen temp=group(eligible xeligible)
		tab eligible xeligible, m
		tab FRS_result temp, m
	}
*/

*****
***** create PREP to deal with wealth quintile for BF & Niger , which have only tertile variables
*****

set more off
foreach survey  in $surveylist{
	use "$data/rawHHQFQ/HHQFQ_`survey'.dta", clear
	gen xsurvey="`survey'"
	keep if HHQ_result==1
	save "$data/prep_`survey'.dta", replace
	}
	
foreach survey  in BFR1 BFR2 BFR3 BFR4 BFR5 BFR6 BFP1  {
	use "$data/prep_`survey'.dta", clear

	/*
	codebook metainstanceID
	sort metainstanceID 
	keep if metainstanceID!=metainstanceID[_n-1] 
	codebook metainstanceID
	*/

		tab xsurvey
		sum score
		sort metainstanceID
		gen score2=score if metainstanceID~=metainstanceID[_n-1]
		xtile wealthquintile=score2 [pweight=HHweight], nq(5)
		replace wealthquintile=wealthquintile[_n-1] if metainstanceID==metainstanceID[_n-1]
		*tab wealthquintile, m
		
		svyset EA_ID, weight(HHweight) strata(strata) , singleunit(centered) 
		svy: tab wealthquintile
		svy: tab wealthquintile if metainstanceID!=metainstanceID[_n-1] 
		
	save "$data/prep_`survey'.dta", replace
	}

foreach survey  in NER2 NER4 {
	use "$data/prep_`survey'.dta", clear
	
		sum score_National 		
		sort metainstanceID
		gen score2=score_National if metainstanceID~=metainstanceID[_n-1]
		xtile wealthquintile=score2 [pweight=HHweight], nq(5)
		replace wealthquintile=wealthquintile[_n-1] if metainstanceID==metainstanceID[_n-1]
		
		svyset EA_ID, weight(HHweight) strata(strata) , singleunit(centered) 
		svy: tab wealthquintile
		svy: tab wealthquintile if metainstanceID!=metainstanceID[_n-1] 
		
	save "$data/prep_`survey'.dta", replace
	}	
	
foreach survey  in NENiameyR1 NENiameyR2 NENiameyR3 NENiameyR4 NENiameyR5 {
	use "$data/prep_`survey'.dta", clear

		sum score_Niamey		
		sort metainstanceID
		gen score2=score_Niamey if metainstanceID~=metainstanceID[_n-1]
		xtile wealthquintile=score2 [pweight=HHweight], nq(5)
		replace wealthquintile=wealthquintile[_n-1] if metainstanceID==metainstanceID[_n-1]
				
		svyset EA_ID, weight(HHweight) strata(strata) , singleunit(centered) 
		*svy: tab wealthquintile
		svy: tab wealthquintile if metainstanceID!=metainstanceID[_n-1] 
				
	save "$data/prep_`survey'.dta", replace
	}		

*****	
***** create PREP to deal with India which has no admin 1 level variable.... 
*****
	
foreach survey  in INRajasthanR1 INRajasthanR2 INRajasthanR3 INRajasthanR4   {
	use "$data/prep_`survey'.dta", clear

		gen state=. 
		
	save "$data/prep_`survey'.dta", replace
	}

*****
***** create PREP to deal with DRC R1 with no "memberID" var
*****

foreach survey  in $DRCsurveylist{
	use "$data/prep_`survey'.dta", clear
	tab xsurvey
	lookfor memberID
}		

foreach survey  in CDKinshasaR1{
	use "$data/prep_`survey'.dta", clear
	
	gen memberID=num_HH_members
	
	save "$data/prep_`survey'.dta", replace
	}
	
*****
***** create PREP to deal with DRC with no "ur" var
*****

foreach survey  in $DRCsurveylist{
	use "$data/prep_`survey'.dta", clear
		capture confirm variable ur
		if !_rc {
			tab ur, m
		}		
}		
	
foreach survey  in CDKinshasaR1 CDKinshasaR2 CDKinshasaR3 CDKinshasaR4 CDKinshasaR5 CDKinshasaR6 CDKinshasaR7 CDKinshasaP1{
	use "$data/prep_`survey'.dta", clear
		gen ur=1	
	save "$data/prep_`survey'.dta", replace
	}	
	
foreach survey  in CDKongoCentralR4 CDKongoCentralR5 CDKongoCentralR6 CDKongoCentralR7 CDKongoCentralP1{
	use "$data/prep_`survey'.dta", clear
		gen ur=2
	save "$data/prep_`survey'.dta", replace
	}	
	
foreach survey  in $DRCsurveylist{
	use "$data/prep_`survey'.dta", clear
		gen strata=1
	save "$data/prep_`survey'.dta", replace
}		

*****
***** create PREP to deal with round in 2.0 surveys
*****
	
/*	
foreach survey  in $surveylistgen2{
	use "$data/prep_`survey'.dta", clear
		tab xsurvey country
	}
*/
	
foreach survey  in $surveylistgen2{
	use "$data/prep_`survey'.dta", clear

		capture confirm variable phase
		if !_rc {
		tostring(phase), replace
		replace phase = "1" if phase=="Phase1"
		destring(phase), replace
		}
			else{
			gen phase=substr(xsurvey, -1, 1)
			destring(phase), replace
			}		
		
		replace country="India_Rajasthan" if country=="India" /*change India P1 country name*/
		
		gen round=.
			replace round=6+phase if country=="Burkina Faso"
			replace round=6+phase if country=="Burkina"
			replace round=7+phase if country=="DRC"
			replace round=7+phase if country=="Kenya"
			replace round=5+phase if country=="Nigeria"		
			replace round=6+phase if country=="Uganda"		
			replace round=4+phase if country=="India_Rajasthan"		
		
		capture confirm variable wealthquintile
		if !_rc {
		tab xsurvey wealthquintile 
		}
			else{
				capture confirm variable wealth
				if !_rc {
				tab xsurvey wealth
				gen wealthquintile=wealth
				}
			}			
		
	save "$data/prep_`survey'.dta", replace
}	
	
***************************	
***** create HR
set more off
foreach survey  in $surveylist{
	use "$data/prep_`survey'.dta", clear
	sum FQweight

	keep if HHQ_result==1
	codebook metainstanceID FQmetainstanceID

	gen byte xeligible=gender==2 & (age>=15 & age<=49)
	
		egen num_HH_members_eligible=sum(xeligible), by(metainstanceID) 
		egen temp=max(xeligible), by(metainstanceID) 
		gen byte eligibleHH=temp>=1
		drop temp xeligible
		lab var num_HH_members_eligible "number of FQ eligible members"
		lab var eligibleHH "HH with at least eligible woman 1+"
				
	sort metainstanceID memberID
	keep if metainstanceID!=metainstanceID[_n-1]
	codebook metainstanceID

		gen prop_eligible=num_HH_members_eligible / num_HH_members
		lab var prop_eligible "prop of HH members FQ eligible"
			
	save "$data/HR_`survey'.dta", replace
	}

***************************	
***** create PR 
foreach survey  in $surveylist{
	use "$data/prep_`survey'.dta", clear
	
	keep if HHQ_result==1
	codebook metainstanceID FQmetainstanceID
	
	*drop hand* water* sanitatio* assets-walls /*problem in DRC R1 & R2*/
	*drop hand* water* sanitatio* /*2.0 surveys don't have hand*? */
	drop water* sanitatio* 
	
	gen byte xeligible=gender==2 & (age>=15 & age<=49)
		lab var xeligible "constructed eligibility for FQ" 
	
	save "$data/PR_`survey'.dta", replace
	}

***************************	
***** create IR 	

foreach survey  in $surveylist{
	use "$data/PR_`survey'.dta", clear
	
	*keep if xeligible==1
	keep if FQmetainstanceID!=""
	
	keep if HHQ_result==1
	keep if FRS_result==1
	
		/*
		foreach survey  in $surveylist{
			use "$data/PR_`survey'.dta, clear
				tab xsurvey
				d usual*
			}
			
		foreach survey  in $surveylist{
			use "$data/PR_`survey'.dta, clear	
				tab xsurvey
				
				capture confirm variable last_night
				if !_rc {
				d last_night, 
				}
				else {
					capture confirm variable usual
					if !_rc {
					d usual
					}	
				}
			}
		*/		
	
		gen xdefacto=0
		capture confirm variable usual_member
		if !_rc {
		replace xdefacto=1 if usual_member==1 | usual_member==3
		}
		else {
			capture confirm variable last_night
			if !_rc {
			replace xdefacto=1 if last_night==1
				}
			}	
			
		capture confirm variable school_cc
		if !_rc {
		rename school_cc school
		}			
	
	keep if xdefacto==1
	
	gen xage=FQ_age
	egen xagegroup5 = cut(FQ_age), at(15,20,25,30,35,40,45,50)
	lab var xage "woman's age at interview" 
	lab var xagegroup5 "woman's age at interview, 5-year group" 	
	
	save "$data/IR_`survey'.dta", replace
	
	}	
		
foreach survey  in $surveylist{
	erase "$data/prep_`survey'.dta"
	}
		
COMPLETED 

foreach survey  in $surveylist{
	use "$data/IR_`survey'.dta", clear 
	tab xsurvey, m
	sum FQweight 
	}

foreach survey  in $surveylistgen2{
	use "$data/IR_`survey'.dta", clear 	
	tab country round, m
	}
	