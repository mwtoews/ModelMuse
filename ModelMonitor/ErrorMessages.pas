unit ErrorMessages;

interface

uses Classes, Generics.Collections;

type
  TAnsiStringList = TList<AnsiString>;

var
  ErrorValues: TAnsiStringList;
  WarningValues: TAnsiStringList;

  // These are error messages that start with a number.
  NumberErrorValues: TAnsiStringList;

implementation


Procedure AssignErrorStrings;
begin
    ErrorValues.Add('INVALID VALUE FOR IFREQ PARAMETER:');
    ErrorValues.Add('INSUFFICIENT MEMORY FOR DE4 SOLVER:');
    ErrorValues.Add('ERROR IN GMG INPUT');
    ErrorValues.Add('ALLOCATION ERROR IN SUBROUTINE GMG1ALG');
    ErrorValues.Add('GMG ASSEMBLY ERROR IN SUBROUTINE GMG1AP');
    ErrorValues.Add('DIS file must be specified for MODFLOW to run');
    ErrorValues.Add('SSFLAG MUST BE EITHER "SS" OR "TR"');
    ErrorValues.Add('STOP EXECUTION');
    ErrorValues.Add('THERE MUST BE AT LEAST ONE TIME STEP IN EVERY STRESS PERIOD');
    ErrorValues.Add('PERLEN MUST NOT BE 0.0 FOR TRANSIENT STRESS PERIODS');
    ErrorValues.Add('TSMULT MUST BE GREATER THAN 0.0');
    ErrorValues.Add('PERLEN CANNOT BE LESS THAN 0.0 FOR ANY STRESS PERIOD');
    ErrorValues.Add('ERROR READING OUTPUT CONTROL INPUT DATA:');
    ErrorValues.Add('CANNOT OPEN');
    ErrorValues.Add('FIRST ENTRY IN NAME FILE MUST BE "LIST".');
    ErrorValues.Add('ILLEGAL FILE TYPE IN NAME FILE:');
    ErrorValues.Add('NAME FILE IS EMPTY.');
    ErrorValues.Add('BAS PACKAGE FILE HAS NOT BEEN OPENED.');
    ErrorValues.Add('ERROR OPENING FILE');
    ErrorValues.Add('ARRAY OPERAND HAS NOT BEEN PREVIOUSLY DEFINED:');
    ErrorValues.Add('NPVAL IN PARAMETER INPUT FILE MUST BE');
    ErrorValues.Add('BUT THE MAXIMUM NUMBER OF PARAMETERS IS');
    ErrorValues.Add('ERROR FOUND IN PARAMETER INPUT FILE.  SEARCH ABOVE');
    ErrorValues.Add('ERROR ENCOUNTERED IN READING PARAMETER INPUT FILE');
//    ErrorValues.Add('IS GREATER THAN');
    ErrorValues.Add('IS GREATER THAN MXACTC');
    ErrorValues.Add('NO-FLOW CELLS CANNOT BE CONVERTED TO SPECIFIED HEAD');
    ErrorValues.Add('IS GREATER THAN MXACTD');
    ErrorValues.Add('IS GREATER THAN MXADRT');
    ErrorValues.Add('is outside of the grid');
    ErrorValues.Add('Blank parameter name in the');
    ErrorValues.Add('Parameter type conflict:');
    ErrorValues.Add('Blank instance name');
    ErrorValues.Add('file specifies undefined instance');
    ErrorValues.Add('*** ERROR: PARAMETER');
    ErrorValues.Add('IS GREATER THAN THE MAXIMUM ALLOWED');
    ErrorValues.Add('file specifies an undefined parameter');
    ErrorValues.Add('Parameter type must be');
    ErrorValues.Add('ILLEGAL ET OPTION CODE');
    ErrorValues.Add('INVALID LAYER NUMBER IN IEVT FOR COLUMN');
    ErrorValues.Add('SIMULATION ABORTING');
    ErrorValues.Add('Aborting. Weights for Auxiliary variables cannot');
    ErrorValues.Add('ABORTING');
    ErrorValues.Add('*** ERROR');
    ErrorValues.Add('IS GREATER THAN MXACTB');
    ErrorValues.Add('INSTANCES ARE NOT SUPPORTED FOR HFB');
    ErrorValues.Add('ERROR DETECTED IN LOCATION DATA OF BARRIER NO.');
    ErrorValues.Add('LAYWT is not 0 and LTHUF is 0 for layer:');
    ErrorValues.Add('Invalid parameter type');
    ErrorValues.Add('Simulation is transient and no storage parameters are');
    ErrorValues.Add('Simulation is steady state and storage parameters are');
    ErrorValues.Add('Simulation is transient and has convertible');
    ErrorValues.Add('Simulation has SYTP parameter(s) defined but has a');
    ErrorValues.Add('STOP SGWF2HUF7VKA');
    ErrorValues.Add('CONSTANT-HEAD CELL WENT DRY');
    ErrorValues.Add('Sy not defined for cell at');
    ErrorValues.Add('***ERROR***');
    ErrorValues.Add('INTERBED STORAGE INAPPROPRIATE FOR A STEADY-STATE');
    ErrorValues.Add('GSFLOW-1.0 cannot simulate transport');
    ErrorValues.Add('--program stopping');
    ErrorValues.Add('MAXIMUM NUMBER OF GRID CELLS ADJACENT TO LAKES');
    ErrorValues.Add('LAK Package requires BCF or LPF');
    ErrorValues.Add('PROGRAM STOPPING');
    ErrorValues.Add('ERROR - NO AQUIFER UNDER LAKE CELL');
    ErrorValues.Add('***NLAKES too large for BUFF in Subroutine GWF2');
    ErrorValues.Add('LAYWET is not 0 and LAYTYP is 0 for layer');
    ErrorValues.Add('LAYWET must be 0 if LAYTYP is 0');
    ErrorValues.Add('IS AN INVALID LAYAVG VALUE -- MUST BE 0, 1, or 2');
    ErrorValues.Add('Negative cell thickness at (layer,row,col)');
    ErrorValues.Add('SIMULATION ABORTED');
    ErrorValues.Add('Negative confining bed thickness below cell (Layer,row,col)');
    ErrorValues.Add('exceeds maximum of');
    ErrorValues.Add('IS GREATER THAN mxwel2');
    ErrorValues.Add('ERROR opening auxillary input file');
    ErrorValues.Add('ILLEGAL RECHARGE OPTION CODE');
    ErrorValues.Add('INVALID LAYER NUMBER IN IRCH');
    ErrorValues.Add('IS GREATER THAN MXACTR');
    ErrorValues.Add('SEGMENT MUST BE GREATER THAN 0 AND LESS THAN NSS');
    ErrorValues.Add('SEGMENTS MUST BE IN ORDER FROM 1 THROUGH NSS');
    ErrorValues.Add('REACHES MUST BE NUMBERED CONSECUTIVELY');
    ErrorValues.Add('RESIDUAL WATER CONTENT IS EQUAL OR GREATER THAN');
    ErrorValues.Add('INITIAL WATER CONTENT IS GREATER THAN SATURATED');
    ErrorValues.Add('PROGRAM TERMINATED');
    ErrorValues.Add('CANNOT SPECIFY MORE THAN NSS STREAM SEGMENTS');
    ErrorValues.Add('CODE STOPPING');
    ErrorValues.Add('SEGMENT NUMBER (NSEG) OUT OF RANGE:');
    ErrorValues.Add('Blank instance name');
    ErrorValues.Add('GREATER THAN MXACTS');
    ErrorValues.Add('SUBSIDENCE CANNOT BE USED');
    ErrorValues.Add('STOPPING');
    ErrorValues.Add('IMPROPER LAYER ASSIGNMENT');
    ErrorValues.Add('GREATER THAN MXACTW');
    ErrorValues.Add('Duplicate parameter name');
    ErrorValues.Add('The number of parameters has exceeded the maximum');
    ErrorValues.Add('Multiplier array has not been defined');
    ErrorValues.Add('There were no zone values specified in the cluster');
    ErrorValues.Add('Zone array has not been defined');
    ErrorValues.Add('NH LESS THAN OR EQUAL TO 0');
    ErrorValues.Add('ERROR:');
    ErrorValues.Add('An observation cannot be placed');
    ErrorValues.Add('NQTCH LESS THAN OR EQUAL TO 0');
    ErrorValues.Add('SEE ABOVE FOR ERROR MESSAGE');
    ErrorValues.Add('DRAIN PACKAGE OF GWF IS NOT OPEN');
    ErrorValues.Add('NUMBER OF OBSERVATIONS LESS THAN OR EQUAL TO 0');
    ErrorValues.Add('GHB PACKAGE OF GWF IS NOT OPEN');
    ErrorValues.Add('RIVER PACKAGE OF GWF IS NOT OPEN');
    ErrorValues.Add('EXCEEDED THE MAXIMUM NUMBER OF INSTANCES:');
    ErrorValues.Add('The above parameter must be defined prior to its use');
    ErrorValues.Add('Number of parameters exceeds MXPAR');
    ErrorValues.Add('EXCEEDED THE MAXIMUM NUMBER OF LIST ENTRIES:');
    ErrorValues.Add('EXCEEDED THE MAXIMUM NUMBER OF INSTANCES:');
    ErrorValues.Add('Parameter type must be:');
    ErrorValues.Add('ERROR CONVERTING');
    ErrorValues.Add('ERROR READING ARRAY CONTROL RECORD');
    ErrorValues.Add('INVALID INTERBLOCK T CODE:');
    ErrorValues.Add('INVALID LAYER TYPE:');
    ErrorValues.Add('LAYER TYPE 1 IS ONLY ALLOWED IN TOP LAYER');
    ErrorValues.Add('FAILED TO MEET SOLVER CONVERGENCE CRITERIA');
    ErrorValues.Add('nlakes dimension problem in lak7');
    ErrorValues.Add('MAXIMUM NUMBER OF GRID CELLS ADJACENT TO LAKES HAS BEEN EXCEEDED WITH CELL');
    ErrorValues.Add('LAK Package requires BCF, LPF, or HUF');
    ErrorValues.Add('THIS WILL CAUSE PROBLEMS IN COMPUTING LAKE STAGE USING THE NEWTON METHOD.');
    //    ErrorValues.Add('***NLAKES too large for BUFF in Subroutine GWF2LAK7SFR7RPS***  STOP EXECUTION');
    ErrorValues.Add('FAILED TO CONVERGE');
    ErrorValues.Add('Can''t find name file');
    ErrorValues.Add('INVALID INPUT FOR GRIDSTATUS IN LGR INPUT FILE:');
    ErrorValues.Add('GRIDSTATUS MUST BE PARENTONLY, CHILDONLY, OR PARENTANDCHILD');
    ErrorValues.Add('IBFLG MUST BE < 0 FOR CHILD GRID');
    ErrorValues.Add('RELAXATION FACTORS RELAXH AND RELAXF MUST BE > 0');
    ErrorValues.Add('NPLBEG IS NOT = 1  REFINEMENT MUST BEGIN IN TOP LAYER');
    ErrorValues.Add('NCPP MUST BE AN ODD INTEGER');
    ErrorValues.Add('NROW AND NCPP DOES NOT ALIGN WITH NPREND - NPRBEG');
    ErrorValues.Add('NCOL AND NCPP DOES NOT ALIGN WITH NPCEND - NPCBEG');
    ErrorValues.Add('NCPPL MUST BE AN ODD INTEGER');
    ErrorValues.Add('VERTICAL REFINEMENT DOES NOT ALIGN WITH NLAY');
    ErrorValues.Add('HEAD BELOW BOTTOM AT SHARED NODE');
    ErrorValues.Add('INVALID INPUT IN BFH FILE:');
    ErrorValues.Add('ISCHILD AND BTEXT ARE NOT COMPATIBLE');
    ErrorValues.Add('MNW1 and MNW2 cannot both be active in the same grid');
    ErrorValues.Add('MNW1 and MNW2 cannot both be active in the same simulation');
    ErrorValues.Add('Failure to converge');
    ErrorValues.Add('NSTACK too small in index');
    ErrorValues.Add('ELEVATION OF STREAM OUTLET MUST BE GREATER THAN OR EQUAL TO THE LOWEST ELEVATION OF THE LAKE.');
    ErrorValues.Add('If the BCF Package is used and unsaturated flow is active then ISFROPT must equal 3 or 5.');
    ErrorValues.Add('Streambed has lower altitude than GW cell bottom. Model stopping');
    ErrorValues.Add('STOPPING SIMULATION');
    ErrorValues.Add('***ERROR: MNW2 PACKAGE DOES NOT SUPPORT');
    ErrorValues.Add('*** BAD RECORD ENCOUNTERED, PCGN DATA INPUT ***');
    ErrorValues.Add('***BAD DATA READ, SUBROUTINE PCGNRP***');
    ErrorValues.Add('UNABLE TO ALLOCATE STORAGE REQUIRED FOR PCG SOLVER');
    ErrorValues.Add('ERROR ENCOUNTERED IN SUBROUTINE PCGNRP');
    ErrorValues.Add('ERROR ENCOUNTERED IN SUBROUTINE PCG_INIT');
    ErrorValues.Add('ERROR ENCOUNTERED IN SUBROUTINE PCG');
    ErrorValues.Add('DIMENSION MISMATCH DISCOVERED');
    ErrorValues.Add('UNKNOWN ERROR');
    ErrorValues.Add('DID NOT CONVERGE');
    ErrorValues.Add('Allocation error in subroutine PCG_init');
    ErrorValues.Add('ARRAY DIAG CONTAINS A NEGATIVE ELEMENT AT NODE');
    ErrorValues.Add('Allocation error in subroutine PCG');
    ErrorValues.Add('Dimension mismatch in subroutine PCG');
    ErrorValues.Add('NOT DEFINED FOR PARAMETER TYPE');
    ErrorValues.Add('HUF and LAK cannot be used together in a simulation');
    ErrorValues.Add('IS LISTED MORE THAN ONCE IN PARAMETER FILE');
    ErrorValues.Add('IN PARAMETER INPUT FILE HAS NOT BEEN DEFINED');
    ErrorValues.Add('ERROR: Proportion must be between 0.0 and 1.0');
    ErrorValues.Add('ERROR DETECTED IN LOCATION DATA OF BARRIER');
    ErrorValues.Add('LAYWT must be 0 if LTHUF is 0');
    ErrorValues.Add('Vertical K is zero in row');
    ErrorValues.Add('Horizontal K is zero in row');
    ErrorValues.Add('MULTKDEP is zero in row');
    ErrorValues.Add('LVDA cannot calculate sensitivities');
    ErrorValues.Add('LAYVKA entered for layer');
    ErrorValues.Add('parameters of type VK can apply only to layers for which');
    ErrorValues.Add('parameters of type VANI can apply only to layers for which');
    ErrorValues.Add('MNWOBS MUST BE > 0');
    ErrorValues.Add('ALLOCATION OF MNW ROUTING ARRAY FAILED');
    ErrorValues.Add('MNW2 NODE ARRAY ALLOCATION INSUFFICIENT');
    ErrorValues.Add('MNW2 Node not in grid; Layer, Row, Col=');
    ErrorValues.Add('ILLEGAL OPTION CODE. SIMULATION ABORTING');
    ErrorValues.Add('Model stopping');
    ErrorValues.Add('CANNOT BE READ FROM RESTART RECORDS');
    ErrorValues.Add('IMPROPER LAYER ASSIGNMENT FOR SUB-WT SYSTEM OF');
    ErrorValues.Add('SUB-WT CANNOT BE USED IN CONJUNCTION WITH QUASI-3D');
    ErrorValues.Add('NEGATIVE EFFECTIVE STRESS VALUE AT (ROW,COL,LAY):');
    ErrorValues.Add('ERROR READING LMT PACKAGE INPUT DATA');
    ErrorValues.Add('ERROR IN LMT PACKAGE INPT DATA:');
    ErrorValues.Add('ERROR IN LMT PACKAGE INPUT DATA:');
    ErrorValues.Add('BETWEEN 1 AND NPER (OF THE DISCRETIZATION INPUT FILE');
    ErrorValues.Add('STREAMFLOW PACKAGE OF GWF IS NOT OPEN');
    ErrorValues.Add('Package has not been defined');
    ErrorValues.Add('MATRIX IS SEVERELY NON-DIAGONALLY DOMINANT');
    ErrorValues.Add('CONJUGATE-GRADIENT METHOD FAILED');
    ErrorValues.Add('DIVIDE BY 0 IN SIP AT LAYER');

//    ErrorValues.Add('NOT FOUND (STOP EXECUTION(GWF2HUF7RPGD))');

    NumberErrorValues.Add('CLUSTERS WERE SPECIFIED, BUT THERE IS SPACE FOR ONLY');
    NumberErrorValues.Add(' NaN');

    // MODFLOW-NWT
    ErrorValues.Add('THIS WILL CAUSE PROBLEMS IN COMPUTING LAKE STAGE USING THE NEWTON METHOD.');
    ErrorValues.Add('***ERROR: MNW PACKAGE DOES NOT SUPPORT HEAD-DEPENDENT');
    ErrorValues.Add('THICKNESS OPTION OF SELECTED FLOW PACKAGE');
    ErrorValues.Add('(MNW DOES FULLY SUPPORT BCF, LPF, AND HUF PACKAGES)');
    ErrorValues.Add('NSTRM IS NEGATIVE AND THIS METHOD FOR SPECIFYING INFORMATION BY REACH HAS BEEN REPLACED BY THE KEYWORD OPTION "REACHINPUT"--PROGRAM STOPPING');
    ErrorValues.Add('Streambed has lower altitude than GW cell bottom. Model stopping');
    ErrorValues.Add('TOO MANY WAVES IN UNSAT CELL');
    ErrorValues.Add('PROGRAM TERMINATED IN UZFLOW-1');
    ErrorValues.Add('***Erroneous value for Input value "Options."***');
    ErrorValues.Add('Check input. Model Stopping.');
    ErrorValues.Add('***Incorrect value for Linear solution method specified. Check input.***');
    ErrorValues.Add('Error in Preconditioning:');
    ErrorValues.Add('Linear solver failed to converge:');
    ErrorValues.Add('Error in gmres: ');
    ErrorValues.Add('***Incorrect value for variable Nonmeth was specified. Check input.***');
    ErrorValues.Add('error in data structure!!');
    ErrorValues.Add('too many iterations!!');
    ErrorValues.Add('error in xmdsfacl');
    ErrorValues.Add('no diagonal in L\U:  row number');
    ErrorValues.Add('error in min. degree ordering');
    ErrorValues.Add('error in subroutine xmdRedBlack');
    ErrorValues.Add('need more space in integer temp. array');
    ErrorValues.Add('error in red-black ordering');
    ErrorValues.Add('error in xmdnfctr (xmbnfac)');
    ErrorValues.Add('error in xmdprpc (xmdordng)');
    ErrorValues.Add('error in xmdprpc (xmdrowrg)');
    ErrorValues.Add('error in xmdprecl (xmdsfacl)');
    ErrorValues.Add('error in xmdprecd (xmdsfacd)');
    ErrorValues.Add('error in xmdcheck');
    ErrorValues.Add('SWR PROCESS REQUIRES LAYCON OF 1 OR 3 FOR');
    ErrorValues.Add('SWR PROCESS REQUIRES USE OF THE BCF, LPF,');
    ErrorValues.Add('COULD NOT PARSE NTABRCH FOR TABULAR DATA ITEM');
    ErrorValues.Add('CONFINED AQUIFERS CANNOT BE SIMULATED WITH SWR');
    ErrorValues.Add('FLOW PACKAGE SPECIFIED INCONSISTENT WITH SWR');
    ErrorValues.Add('SWR 4D: COULD NOT PARSE NTABRCH');
    ErrorValues.Add('ERROR CANNOT REUSE');
    ErrorValues.Add('ERROR REACH ITEM');
    ErrorValues.Add('MUST BE GREATER THAN');
    // THETA MUST BE LESS THAN is an informative message not an error message.
//    ErrorValues.Add('MUST BE LESS THAN');
    ErrorValues.Add('MUST BE LESS THAN OR');
    ErrorValues.Add('MUST BE LESS THAN 4');
    ErrorValues.Add('MUST NOT EQUAL');
    ErrorValues.Add('RTMAX EXCEEDS MODFLOW DELT');
    ErrorValues.Add('REACHNO EXCEEDS NREACHES');
    ErrorValues.Add('REACHNO LESS THAN ONE');
    ErrorValues.Add('NCONN LESS THAN ZERO');
    ErrorValues.Add('ICONN EXCEEDS NREACHES');
    ErrorValues.Add('ICONN LESS THAN ONE');
    ErrorValues.Add('REACH LAYER EXCEEDS NLAY');
    ErrorValues.Add('REACH ROW EXCEEDS NROW');
    ErrorValues.Add('REACH COL EXCEEDS NCOL');
    ErrorValues.Add('MUST BE EQUAL TO NREACHES');
    ErrorValues.Add('MUST NOT EXCEED NREACHES');
    ErrorValues.Add('ERROR SPECIFYING ISWRBND');
    ErrorValues.Add('POSITIVE REACH RAIN VALUE REQUIRED');
    ErrorValues.Add('POSITIVE REACH EVAP VALUE REQUIRED');
    ErrorValues.Add('ISTRRCH.LT.1 OR .GT.NREACHES');
    ErrorValues.Add('ISTRNUM.LT.1 OR .GT.REACH(ISTRRCH)%NSTRUCT');
    ErrorValues.Add('SIMULATED SWR1 STAGE STRCRIT ONLY FOR');
    ErrorValues.Add('PROGRAMMING ERROR: UNDEFINED ISTRTYPE');
    ErrorValues.Add('SWR SOLUTION DID NOT CONVERGE');
    ErrorValues.Add('COULD NOT READ FROM UNIT Iu');
    ErrorValues.Add('jstack.GT.nstack GWFSWR');
    ErrorValues.Add('SPECIFIED STRUCTURE CONNECTION ERRORS:');
    ErrorValues.Add('INVALID STRUCTURE CONNECTION FOR REACH');
    ErrorValues.Add('ERRORS IN SPECIFIED REACH');
    ErrorValues.Add('4B: ASSYMETRY IN REACH CONNECTIONS');
    ErrorValues.Add('COULD NOT ALLOCATE RCHGRP(n)%REACH');
    ErrorValues.Add('MULTIPLE DW CONNECTIONS TO THE SAME DW RCHGRP');
    ErrorValues.Add('MULT. ROUTING APPROACHES FOR AT LEAST');
    ErrorValues.Add('KRCH MUST BE SET TO 1 FOR REACH');
    ErrorValues.Add('PROGRAMMING ERROR:');
    ErrorValues.Add('SWR STAGE FILE NOT');
    ErrorValues.Add('NO DATA READ FROM SPECIFIED SWR1 STAGE FILE');

    // FMP
    ErrorValues.Add('INPUT-ERROR:');
    ErrorValues.Add('CROP CONSUMPTIVE USE FLAG MUST BE 1,2,3,OR 4!');
    ErrorValues.Add('NON-ROUTED SW-DELIVERY FLAG MUST BE 0 OR 1!');
    ErrorValues.Add('IRDFL MUST BE -1, 0, OR 1!');
    ErrorValues.Add('NOT A VALID ENTRY IF SFR PACKAGE IS USED');
    ErrorValues.Add('ROUTED SW-DELIVERY FLAG MUST BE -1 OR 1!');
    ErrorValues.Add('SOIL-ID CANNOT BE ZERO IN CELLS THAT HOLD A NON-ZERO FARM-ID:');
    ErrorValues.Add('INPUT ERROR:');
    ErrorValues.Add('YOU HAVE TWO OPTIONS TO CORRECT THE ERROR:');
    ErrorValues.Add('FRACTION OF INEFFICIENT LOSSES TO SURFACEWATER RUNOFF');
    ErrorValues.Add('THE SCALE FACTOR DOES NOT APPLY TO ANY FIELD');
    ErrorValues.Add('NUMBER OF CONSTRAINTS NOT EQUAL TO LHS<=RHS + LHS>=RHS + LHS=RHS');
    ErrorValues.Add('BAD INPUT TABLEAU IN LINOPT');
    ErrorValues.Add('ROOT MUST BE BRACKETED IN RTFUNC');
    ErrorValues.Add('TOO MANY BISECTIONS WHEN SOLVING ANALTYICAL FUNCTION');
    ErrorValues.Add('IS GREATER THAN MXACTFW');
    ErrorValues.Add('CANNOT BE COMBINED WITH IALLOT>1');
    ErrorValues.Add('MUST HAVE A NEGATIVE FARM-WELL ID');
    ErrorValues.Add('Blank instance name in the');
    ErrorValues.Add('HAS ALREADY BEEN ACTIVATED THIS STRESS PERIOD');

    // SWR
    ErrorValues.Add('DIRECT RUNOFF UNIT MUST BE >= 0');
    ErrorValues.Add('MUST BE GREATER THAN');
    ErrorValues.Add('MUST BE GREATER  THAN');
    ErrorValues.Add('ISOLVER MUST MUST BE');
    ErrorValues.Add('ISOLVER MUST BE');
    ErrorValues.Add('NOUTER MUST NOT EQUAL 0');
    ErrorValues.Add('MUST BE LESS THAN');
    ErrorValues.Add('EXCEEDS NREACHES');
    ErrorValues.Add('LESS THAN ONE');
    ErrorValues.Add('LESS THAN ZERO');
    ErrorValues.Add('REACH LAYER EXCEEDS NLAY');
    ErrorValues.Add('REACH ROW EXCEEDS NROW');
    ErrorValues.Add('REACH COL EXCEEDS NCOL');
    ErrorValues.Add('COULD NOT PARSE NTABRCH');
    ErrorValues.Add('CONFINED AQUIFERS CANNOT BE SIMULATED WITH SWR');
    ErrorValues.Add('FLOW PACKAGE SPECIFIED INCONSISTENT WITH SWR');
    ErrorValues.Add('MUST BE EQUAL TO');
    ErrorValues.Add('MUST NOT EXCEED');
    ErrorValues.Add('SHOULD BE SPECIFIED AS');
    ErrorValues.Add('POSITIVE REACH RAIN VALUE REQUIRED');
    ErrorValues.Add('POSITIVE REACH EVAP VALUE REQUIRED');
    ErrorValues.Add('ISTRRCH.LT.1 OR .GT.NREACHES');
    ErrorValues.Add('ISTRNUM.LT.1 OR .GT.REACH(ISTRRCH)%NSTRUCT');
    ErrorValues.Add('SIMULATED SWR1 STAGE STRCRIT ONLY FOR');
    ErrorValues.Add('STAGE CANNOT BE SPECIFIED USING ANOTHER');
    ErrorValues.Add('INVALID SOURCE REACH DEFINING STAGE FOR');
    ErrorValues.Add('INVALID STRUCTURE CONNECTION');
    ErrorValues.Add('ASSYMETRY IN REACH CONNECTIONS');
    ErrorValues.Add('COULD NOT ALLOCATE');
    ErrorValues.Add('MULTIPLE DW CONNECTIONS TO THE SAME DW RCHGRP');
    ErrorValues.Add('ROUTING APPROACHES FOR AT LEAST');
    ErrorValues.Add('KRCH MUST BE SET TO 1');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');
//    ErrorValues.Add('aaa');


//    WarningValues.Add('**WARNING**');
//    WarningValues.Add('*** WARNING ***');
//    WarningValues.Add('***WARNING***  FOR CHD CELL');
    WarningValues.Add('OUTPUT CONTROL WAS SPECIFIED FOR A NONEXISTENT');
    WarningValues.Add('NO FLOW EQUATION TO SOLVE IN TIME STEP');
    WarningValues.Add('CELL CONVERSIONS FOR ITER');
    WarningValues.Add('****Units are undefined');
    WarningValues.Add('ELIMINATED BECAUSE ALL HYDRAULIC');
    WarningValues.Add('Nodes are often elminated for the following reasons');
//    WarningValues.Add('WARNING-- COMPUTED STAGE OF ');
    WarningValues.Add('IF WETDRY FLAG NOT TURNED ON, VERTICAL LEAKANCES ARE NOT SAVED:');
    WarningValues.Add('THEREFORE, LAKE/AQUIFER CONDUCTANCES ARE BASED SOLELY ON LAKEBED SPECIFICATION');
    WarningValues.Add('NODE(S) ADJACENT TO LAKE IN CONFINED LAYER:');
    WarningValues.Add('LAKE/AQUIFER CONDUCTANCES BASED SOLELY ON LAKEBED SPECIFICATION');
    WarningValues.Add('NOTE: INFORMATION ABOUT CALCULATED LAKE/AQUIFER CONDUCTANCES WHEN USING BCF PACKAGE FOLLOWS:');
//    WarningValues.Add('*** WARNING: IBOUND = ');
//    WarningValues.Add('WARNING -- SUM OF INTERLAKE FLUXES ');
//    WarningValues.Add(' WARNING****  OUTFLOWING STREAM SEGMENT');
    WarningValues.Add('Note: Solution may be sensitive to value of HWtol;');
    WarningValues.Add('adjust value if solution fails to converge');
    WarningValues.Add('deactivated this time step because');
//    WarningValues.Add('deactivated this time step because Hnew<bottom elev. of cell');
//    WarningValues.Add('deactivated this time step because IBOUND=0');
    WarningValues.Add('DEACTIVATED THIS STRESS PERIOD BECAUSE ALL NODES WERE DEACTIVATED');
//    WarningValues.Add('***WARNING*** Specified-head condition should not exist in same cell as a multi-node well');
//    WarningValues.Add('***WARNING*** CWC<0 in Well ');
//    WarningValues.Add('***WARNING*** CWC<0 reset to CWC=0');
    WarningValues.Add('WARNING');
    WarningValues.Add('LARGE RESIDUAL L2 NORM FOR THIS SOLUTION');
    WarningValues.Add('CHECK THAT MASS BALANCE ERROR NOT EXCESSIVE');
    WarningValues.Add('MXLGRITER EXCEEDED FOR GRID NUMBER');
    WarningValues.Add('CHECK BUDGET OF PARENT GRID TO ASSESS QUALITY OF THE LGR SOLUTION');
    WarningValues.Add('INITIAL WATER CONTENT IS LESS THAN RESIDUAL WATER CONTENT FOR STREAM SEGMENT');
    WarningValues.Add('A NEGATIVE VALUE FOR FLOW WAS SPECIFIED IN A SFR TABULAR INFLOW FILE. VALUE WILL BE RESET TO ZERO');
    WarningValues.Add(' ***Warning in SFR2*** ');
    WarningValues.Add('Fraction of diversion for each cell in group sums to a value greater than one.');
    WarningValues.Add('NEGATIVE LAKE OUTFLOW NOT ALLOWED;');
    WarningValues.Add('PET DIFF ERROR');
    WarningValues.Add('FAILURE TO MEET SOLVER CONVERGENCE CRITERIA');
    WarningValues.Add('CONTINUING EXECUTION');
    WarningValues.Add('OMITTED BECAUSE IBOUND=0 FOR CELL(S)');
    WarningValues.Add('REQUIRED FOR MULTILAYER INTERPOLATION');
    WarningValues.Add('For the cells listed below, one of two conditions exist');
    WarningValues.Add('ISOLATED CELL IS BEING ELIMINATED');
    WarningValues.Add('INCONSISTANT DATA HAS BEEN ENTERED');
    WarningValues.Add('PCGN ASSEMBLER HAS DISCOVERED AN ADDITIONAL INACTIVE CELL');
    WarningValues.Add('***PROVISIONAL CONVERGENCE***');
//    WarningValues.Add('WARNING: RATIO_E NEGATIVE IN SUBROUTINE NONLINEAR');
    WarningValues.Add('A ZERO PIVOT WAS ENCOUNTERED AT LOCATION');
    WarningValues.Add('A NEGATIVE PIVOT WAS ENCOUNTERED AT LOCATION');
    WarningValues.Add('PRECONDITIONED CONJUGATE GRADIENT SOLVER CANNOT');
    WarningValues.Add('THE DOMAIN INTEGRITY ANALYSIS IS DEFECTIVE');
    WarningValues.Add('THE DOMAIN INTEGRITY APPEARS TO BE COMPROMIZED');
    WarningValues.Add('SECTIONS OF THE LAKE BOTTOM HAVE BECOME DRY');
    WarningValues.Add('OMITTED BECAUSE IBOUND=0');
    WarningValues.Add('IS DRY -- OMIT');
    WarningValues.Add('ARE BELOW THE BOTTOM');
    WarningValues.Add('When solver convergence criteria are not met');
    WarningValues.Add('NPVAL in parameter file is 0');
    WarningValues.Add('FHB STEADY-STATE OPTION FLAG WILL BE IGNORED');
    WarningValues.Add('SPECIFIED-HEAD VALUE IGNORED AT ROW');
    WarningValues.Add('GAGE PACKAGE ACTIVE EVEN THOUGH SFR AND LAK');
    WarningValues.Add('NUMGAGE=0, SO GAGE IS BEING TURNED OFF');
    WarningValues.Add('Warning');
    WarningValues.Add('IOHUFFLWS NOT FOUND AND WILL BE SET TO BE ZERO');
    WarningValues.Add('Simulation is steady state and SYTP parameter(s) are');
    WarningValues.Add('Invalid array type was found on the following');
    WarningValues.Add('Hydrograph Record will be ignored.');
    WarningValues.Add('Coordinates of the following record are');
    WarningValues.Add('Invalid interpolation type was found on the');
    WarningValues.Add('Invalid streamflow array was found on the following');
    WarningValues.Add('Hydrograph specified for non-existent stream reach');
    WarningValues.Add('Invalid SFR array was found on the following');
    WarningValues.Add('Hydrograph specified for non-existent stream reach');
    WarningValues.Add('BEEN SUPERSEDED BY THE SUBSIDENCE AND AQUIFER-SYSTEM');
    WarningValues.Add('JUST GONE DRY');
    WarningValues.Add('IS DRY');
    WarningValues.Add('SECTIONS OF THE LAKE BOTTOM HAVE BECOME DRY.');
    WarningValues.Add('MNW2 node in dry cell, Q set to 0.0');
    WarningValues.Add('Note-- the following MNW2 well went dry:');
    WarningValues.Add('Partial penetration solution did not');
    WarningValues.Add('Note: z2>z1 & distal part of well is shallower.');
    WarningValues.Add('PROGRAM CONTINUES TO NEXT TIME STEP BECAUSE NNN');
    WarningValues.Add('SFR PACKAGE BEING TURNED OFF');
    WarningValues.Add('NUMBER OF TRAILING WAVES IS LESS THAN ZERO');
    WarningValues.Add('RESETTING UNSATURATED FLOW TO BE INACTIVE');
    WarningValues.Add('IS LESS THAN 1.0E-07: SETTING SLOPE TO');
    WarningValues.Add('SECANT METHOD FAILED TO FIND SOLUTION FOR');
    WarningValues.Add('HIGHEST DEPTH LISTED IN RATING TABLE OF ');
    WarningValues.Add('two cross-section points are identical');
    WarningValues.Add('Non-convergence in ROUTE_CHAN');
    WarningValues.Add('VERTICAL FLOW IN VADOSE ZONE IS');
    WarningValues.Add('SETTING UZF PACKAGE TO INACTIVE');
    WarningValues.Add('NUMBER OF TRAILING WAVES IS LESS THAN ZERO');
    WarningValues.Add('RESETTING THE NUMBER OF WAVE SETS TO BE 20');
    WarningValues.Add('SETTING UNSATURATED FLOW IN CELL TO INACTIVE');
    WarningValues.Add('Removing gage');
    WarningValues.Add('SETTING RATE TO ZERO');
    WarningValues.Add('SETTING DEPTH TO ONE');
    WarningValues.Add('SETTING EXTINCTION WATER CONTENT EQUAL TO RESIDUAL WATER CONTENT');
    WarningValues.Add('UNSATURATED FLOW WILL NOT BE ADDED TO ANY LAYER--');
    WarningValues.Add('Deactivating the Well Package because MXACTW=0');
    WarningValues.Add('WARNING READING LMT PACKAGE INPUT DATA:');
    WarningValues.Add('INTERPOLATION FOR HEAD OBS#');
    WarningValues.Add('Observation within a steady-state time step has');
    WarningValues.Add('the observation type does not allow this');
    WarningValues.Add('The observation is being moved to the end of the time step.');
    WarningValues.Add('An observation cannot be placed at the very');
    WarningValues.Add('HEADS AT DRAIN CELLS ARE BELOW THE');
    WarningValues.Add('ALL CELLS INCLUDED IN THIS OBSERVATION ARE DRY');
    WarningValues.Add('THESE CONDITIONS DIMINISH THE IMPACT');
    WarningValues.Add('these conditions can diminish the impact');
    WarningValues.Add('COMBINED LAKE/AQUIFER CONDUCTANCES BASED SOLELY ON LAKEBED');
    WarningValues.Add('Well is inactive');
    WarningValues.Add('Extremely thin cell');

    // MODFLOW-NWT
//    WarningValues.Add('*** WARNING *** NEGATIVE LAKE OUTFLOW NOT ALLOWED;');
    WarningValues.Add('NEGATIVE PUMPING RATES WILL BE REDUCED IF HEAD ');
    WarningValues.Add('FALLS WITHIN THE INTERVAL PSIRAMP TIMES THE CELL');
    WarningValues.Add('THICKNESS. THE VALUE SPECIFIED FOR PHISRAMP IS');
    WarningValues.Add('TO AVOID PUMPING WATER FROM A DRY CELL');
    WarningValues.Add('THE PUMPING RATE WAS REDUCED FOR CELL');
    WarningValues.Add('warning in xmdcheck');
    WarningValues.Add('UNRECOGNIZED SWR1 OPTION:');
    WarningValues.Add('*** MODFLOW CONVERGENCE FAILURE ***');
    WarningValues.Add('**Active cell surrounded by inactive cells**');
    WarningValues.Add('**Resetting cell to inactive**');

//    FMP
    WarningValues.Add('CORRECTION FOR');
    WarningValues.Add('SOLVER CONTINUES TO ITERATE WITH ADJUSTED');
    WarningValues.Add('HCLOSE MUST BE SMALLER');
    WarningValues.Add('RESOURCES THAT ARE AVAILABLE AT THE RATE OF A CONSTRAINED SUPPLY');
    WarningValues.Add('GROUNDWATER PUMPING REQ.  < CUMULATIVE MAXIMUM CAPACITY');
    WarningValues.Add('ROUTED SURFACE-WATER REQ. < AVAILABLE ROUTED SW DELIVERY');
    WarningValues.Add('NON-ROUTED SW. REQ.       < AVAILABLE NON-ROUTED SW DELIVERY');
    WarningValues.Add('NO ACTIVE FARM CANAL REACHES ARE WITHIN');
    WarningValues.Add('NO POINT OF DIVERSION FOR SEMI-ROUTED DELIVERY SPECIFIED:');
    WarningValues.Add('NO ACTIVE FARM DRAIN REACHES ARE WITHIN');
    WarningValues.Add('NO POINT OF RECHARGE FOR SEMI-ROUTED RETURNFLOW SPECIFIED:');
//    WarningValues.Add('aaa');

//    WarningValues.Add('aaa');
//    WarningValues.Add('aaa');
//    WarningValues.Add('aaa');
//    WarningValues.Add('aaa');
end;

initialization
  ErrorValues := TAnsiStringList.Create;
  WarningValues := TAnsiStringList.Create;
  NumberErrorValues := TAnsiStringList.Create;
  AssignErrorStrings;

finalization
  NumberErrorValues.Free;
  ErrorValues.Free;
  WarningValues.Free;

end.
