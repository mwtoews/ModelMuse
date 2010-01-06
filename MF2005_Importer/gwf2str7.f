      MODULE GWFSTRMODULE
        INTEGER,SAVE,POINTER   ::MXSTRM,NSTREM,NSS,NTRIB,NDIV,ICALC
        INTEGER,SAVE,POINTER   ::ISTCB1,ISTCB2,IPTFLG
        REAL,   SAVE,POINTER   ::CONST
        INTEGER,SAVE,POINTER   ::NPSTR,ISTRPB
        REAL,   SAVE,  POINTER,  DIMENSION(:,:)  ::STRM
        REAL,   SAVE,  POINTER,  DIMENSION(:)    ::ARTRIB
        INTEGER,SAVE,  POINTER,  DIMENSION(:,:)  ::ISTRM
        INTEGER,SAVE,  POINTER,  DIMENSION(:,:)  ::ITRBAR
        INTEGER,SAVE,  POINTER,  DIMENSION(:)    ::IDIVAR
        INTEGER,SAVE,  POINTER,  DIMENSION(:)    ::NDFGAR
      TYPE GWFSTRTYPE
        INTEGER,POINTER   ::MXSTRM,NSTREM,NSS,NTRIB,NDIV,ICALC
        INTEGER,POINTER   ::ISTCB1,ISTCB2,IPTFLG
        REAL,   POINTER   ::CONST
        INTEGER,POINTER   ::NPSTR,ISTRPB
        REAL,   POINTER,  DIMENSION(:,:)  ::STRM
        REAL,   POINTER,  DIMENSION(:)    ::ARTRIB
        INTEGER,POINTER,  DIMENSION(:,:)  ::ISTRM
        INTEGER,POINTER,  DIMENSION(:,:)  ::ITRBAR
        INTEGER,POINTER,  DIMENSION(:)    ::IDIVAR
        INTEGER,POINTER,  DIMENSION(:)    ::NDFGAR
      END TYPE
      TYPE(GWFSTRTYPE), SAVE  ::GWFSTRDAT(10)
      END MODULE GWFSTRMODULE

      SUBROUTINE GWF2STR7AR(IN,IGRID)
C     *****************************************************************C
C     ALLOCATE ARRAY STORAGE FOR STREAMS
C     *****************************************************************C
C
C     SPECIFICATIONS:
C     -----------------------------------------------------------------C
      USE GLOBAL,      ONLY:IOUT,NCOL,NROW,NLAY
      USE GWFSTRMODULE,ONLY:MXSTRM,NSTREM,NSS,NTRIB,NDIV,ICALC,ISTCB1,
     1                      ISTCB2,IPTFLG,CONST,NPSTR,ISTRPB,
     2                      STRM,ARTRIB,ISTRM,ITRBAR,IDIVAR,NDFGAR
C
      CHARACTER*200 LINE
C     -----------------------------------------------------------------C
      ALLOCATE(MXSTRM,NSTREM,NSS,NTRIB,NDIV,ICALC)
      ALLOCATE(ISTCB1,ISTCB2,IPTFLG)
      ALLOCATE(CONST)
      ALLOCATE(NPSTR,ISTRPB)
C
C1------IDENTIFY PACKAGE AND INITIALIZE NSTREM.
      WRITE(IOUT,*) 'STR:'
!      WRITE(IOUT,1) IN
!    1 FORMAT(1X,/1X,'STR -- STREAM PACKAGE, VERSION 7, 5/2/2005 ',
!     1'INPUT READ FROM UNIT ',I4)
      NSTREM=0
C
C2------ READ MXACTS, NSS, NTRIB, ISTCB1, AND ISTCB2.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPSTR,MXPS)
      READ(LINE,3)MXACTS,NSS,NTRIB,NDIV,ICALC,CONST,ISTCB1,ISTCB2
    3 FORMAT(5I10,F10.0,2I10)
      IF(MXACTS.LT.0)MXACTS=0
      IF(NSS.LT.0)NSS=0
      WRITE(IOUT,*)'MXACTS,NSS,NTRIB,NDIV,ICALC,CONST,ISTCB1,ISTCB2:'
      WRITE(IOUT,*)MXACTS,NSS,NTRIB,NDIV,ICALC,CONST,ISTCB1,ISTCB2
!      WRITE(IOUT,4)MXACTS,NSS,NTRIB
!    4 FORMAT(1X,'MAXIMUM OF ',I6,' ACTIVE STREAM NODES AT ONE TIME',/
!     1   1X,'NUMBER OF STREAM SEGMENTS IS ',I6,/
!     2   1X,'NUMBER OF STREAM TRIBUTARIES IS ',I6)
!      IF(NDIV.GT.0) WRITE(IOUT,5)
!    5 FORMAT(1H ,'DIVERSIONS FROM STREAMS HAVE BEEN SPECIFIED')
!      IF(ICALC.GT.0) WRITE(IOUT,6) CONST
!    6 FORMAT(1X,'STREAM STAGES WILL BE CALCULATED USING A CONSTANT OF '
!     1       ,F10.4)
!      IF(ISTCB1.GT.0) WRITE(IOUT,7) ISTCB1,ISTCB2
!    7 FORMAT(1X,'CELL BUDGETS WILL BE SAVED ON UNITS ',I4,' AND ',I4)
C
C
      ISTRPB=MXACTS+1
      MXSTRM=MXACTS+MXPS
C
C4------ALLOCATE SPACE FOR STRM, ISTRM, ITRBAR, ARTRIB, IDIVAR,
C4------AND NDFGAR.
      ALLOCATE (STRM(11,MXSTRM))
      ALLOCATE (ISTRM(5,MXSTRM))
      ALLOCATE (ITRBAR(NSS,NTRIB))
      ALLOCATE (ARTRIB(NSS))
      ALLOCATE (IDIVAR(NSS))
      ALLOCATE (NDFGAR(NSS))
C

C-------READ NAMED PARAMETERS.
      IRDFLG = 0
      WRITE(IOUT,1000) NPSTR
 1000 FORMAT(1X,//1X,I5,' Stream parameters')
      IF(NPSTR.GT.0) THEN
        LSTSUM=ISTRPB
        DO 20 K=1,NPSTR
          LSTBEG=LSTSUM
          CALL UPARLSTRP(LSTSUM,MXSTRM,IN,IOUT,IP,'STR','STR',1,
     &                   NUMINST)
          NLST=LSTSUM-LSTBEG
          IF (NUMINST.EQ.0) THEN
C-------READ PARAMETER WITHOUT INSTANCES
            CALL SGWF2STR7R(NLST,MXSTRM,STRM,ISTRM,LSTBEG,IN,
     &                      IOUT,NCOL,NROW,NLAY,IRDFLG)
          ELSE
C-------READ INSTANCES
            NINLST=NLST/NUMINST
            DO 10 I=1,NUMINST
              CALL UINSRP(I,IN,IOUT,IP,1)
              CALL SGWF2STR7R(NINLST,MXSTRM,STRM,ISTRM,LSTBEG,IN,
     &                      IOUT,NCOL,NROW,NLAY,IRDFLG)
              LSTBEG=LSTBEG+NINLST
   10       CONTINUE
          END IF
   20   CONTINUE
      END IF
C
C6------RETURN
      CALL SGWF2STR7PSV(IGRID)
      RETURN
      END
      SUBROUTINE GWF2STR7RP(IN,IGRID)
C     *****************************************************************C
C     READ STREAM DATA:  INCLUDES SEGMENT AND REACH NUMBERS, CELL
C         SEQUENCE OF SEGMENT AND REACH, FLOW INTO MODEL AT BOUNDARY,
C         STREAM STAGE, STREAMBED CONDUCTANCE, AND STREAMBED TOP AND
C         BOTTOM ELEVATIONS
C     *****************************************************************C
C
C     SPECIFICATIONS:
C     -----------------------------------------------------------------C
      USE GLOBAL,      ONLY:IOUT,NCOL,NROW,NLAY
      USE GWFSTRMODULE,ONLY:MXSTRM,NSTREM,NSS,NTRIB,NDIV,ICALC,
     1                      IPTFLG,CONST,NPSTR,ISTRPB,
     2                      STRM,ARTRIB,ISTRM,ITRBAR,IDIVAR,NDFGAR
C     -----------------------------------------------------------------C
      CALL SGWF2STR7PNT(IGRID)
	WRITE(IOUT,*) 'STR:'
C
C1A-----IF MXSTREAM IS LESS THAN 1 THEN STREAM IS INACTIVE. RETURN.
      IF(MXSTRM.LT.1) RETURN
C
C1B-----READ ITMP(NUMBER OF STREAM CELLS OR PARAMETERS).
      READ(IN,1)ITMP,IRDFLG,IPTFLG
    1 FORMAT(4I10)
      WRITE(IOUT,*)'ITMP,IRDFLG,IPTFLG:'
      WRITE(IOUT,*)ITMP,IRDFLG,IPTFLG
C
C
      MXACTS=ISTRPB-1
      IF(NPSTR.LE.0) THEN
C
C2A-----IF ITMP <0 THEN REUSE NON-PARAMETER DATA FROM LAST STRESS PERIOD.
         IF(ITMP.LT.0) THEN
!            WRITE(IOUT,2)
!    2       FORMAT(/,'REUSING STREAM NODES FROM LAST STRESS PERIOD')
            RETURN
         ELSE
C
C3A-----IF THERE ARE NEW NON-PARAMETER STREAM CELLS, READ THEM
            NSTREM=ITMP
            IF(NSTREM.GT.MXACTS) THEN
               WRITE(IOUT,99) NSTREM,MXACTS
   99          FORMAT(1X,/1X,'THE NUMBER OF ACTIVE STREAM CELLS (',
     1              I6,') IS GREATER THAN MXACTS(',I6,')')
               CALL USTOP(' ')
            END IF
            CALL SGWF2STR7R(NSTREM,MXSTRM,STRM,ISTRM,1,IN,IOUT,NCOL,
     1             NROW,NLAY,IRDFLG)
         END IF
      ELSE
C
C1C-----IF THERE ARE ACTIVE STR PARAMETERS, READ THEM AND SUBSTITUTE
         NSTREM=0
         CALL PRESET('STR')
         IF(ITMP.GT.0) THEN
            DO 100 N=1,ITMP
            CALL UPARLSTLOC(IN,'STR',IOUT,'STR',IBEG,IEND,PV)
            NLST=IEND-IBEG+1
            NSTREM=NSTREM+NLST
            IF(NLST.GT.MXACTS) THEN
               WRITE(IOUT,99) NLST,MXACTS
               CALL USTOP(' ')
            END IF
            DO 50 I=1,NLST
            II=NSTREM-NLST+I
            III=IBEG+I-1
            DO 40 J=1,5
            STRM(J,II)=STRM(J,III)
            ISTRM(J,II)=ISTRM(J,III)
   40       CONTINUE
            STRM(3,II)=STRM(3,II)*PV
            IF(IRDFLG.EQ.0) THEN
!               IF (N.EQ.1 .AND. I.EQ.1) WRITE(IOUT,4)
!    4 FORMAT(/,4X,'LAYER   ROW    COL    SEGMENT   REACH   STREAMFLOW',
!     16X,'STREAM    STREAMBED     STREAMBED BOT  STREAMBED TOP',/27X,
!     2'NUMBER   NUMBER                   STAGE   CONDUCTANCE',6X,
!     3'ELEVATION      ELEVATION',/3X,110('-'))
!               WRITE(IOUT,6)(ISTRM(J,II),J=1,5),(STRM(J,II),J=1,5)
            ENDIF
 !   6       FORMAT(1X,1X,I6,2I7,2I9,7X,G11.4,G12.4,G11.4,4X,2G13.4)
   50       CONTINUE
C
  100       CONTINUE
         END IF
      END IF
C
C3------PRINT NUMBER OF REACHES IN CURRENT STRESS PERIOD.
!      WRITE (IOUT,101) NSTREM
!  101 FORMAT(1X,/1X,I6,' STREAM REACHES')
C
C4------IF THERE ARE NO STREAM REACHES THEN RETURN.
      IF(NSTREM.EQ.0) RETURN
C
C6----READ AND PRINT DATA IF STREAM STAGE IS CALCULATED.
      IF(ICALC.LE.0) GO TO 300
!      IF(IRDFLG.EQ.0) WRITE(IOUT,7)
!    7 FORMAT(/,4X,'LAYER',3X,'ROW',4X,'COL   ',' SEGMENT',3X,
!     1'REACH',8X,'STREAM',13X,'STREAM',10X,'ROUGH',/27X,'NUMBER',3X,
!     2 'NUMBER',8X,'WIDTH',14X,'SLOPE',10X,'COEF.',/3X,110('-'))
      DO 280 II=1,NSTREM
      READ(IN,8) STRM(6,II),STRM(7,II),STRM(8,II)
    8 FORMAT(3F10.0)
      WRITE(IOUT,*) 'Width Slope Rough:'
      WRITE(IOUT,*) STRM(6,II),STRM(7,II),STRM(8,II)
!      IF(IRDFLG.EQ.0) WRITE(IOUT,9)ISTRM(1,II),
!     &    ISTRM(2,II),ISTRM(3,II),ISTRM(4,II),ISTRM(5,II),
!     1    STRM(6,II),STRM(7,II),STRM(8,II)
!    9 FORMAT(2X,I6,2I7,2I9,7X,G12.4,4X,G13.4,4X,G12.4)
  280 CONTINUE
C
C7------INITIALIZE ALL TRIBUTARY SEGMENTS TO ZERO.
  300 DO 320 IK=1,NSS
      DO 320 JK=1,NTRIB
      ITRBAR(IK,JK)=0
  320 CONTINUE
C
C8-----INITIALIZE DIVERSION SEGMENT ARRAY TO ZERO.
      DO 325 IK=1,NSS
      IDIVAR(IK)=0
  325 CONTINUE
C
C9-----READ AND PRINT TRIBUTARY SEGMENTS.
      IF(NTRIB.LE.0) GO TO 343
!      IF(IRDFLG.EQ.0) WRITE(IOUT,10)NTRIB
!   10 FORMAT(/,30X,'MAXIMUM NUMBER OF TRIBUTARY STREAMS IS ',I6,//1X,
!     1 20X,'STREAM SEGMENT',15X,'TRIBUTARY STREAM SEGMENT NUMBERS')
      DO 340 IK=1,NSS
      READ(IN,11) (ITRBAR(IK,JK),JK=1,NTRIB)
   11 FORMAT(10I5)
      WRITE(IOUT,*) '(ITRBAR(IK,JK),JK=1,NTRIB):'
      WRITE(IOUT,*) (ITRBAR(IK,JK),JK=1,NTRIB)
!      IF(IRDFLG.EQ.0) WRITE(IOUT,12) IK,(ITRBAR(IK,JK),JK=1,NTRIB)
!   12 FORMAT(19X,I6,20X,10I5)
  340 CONTINUE
C
C10----READ AND PRINT DIVERSION SEGMENTS NUMBERS.
  343 IF(NDIV.LE.0) GO TO 350
!      IF(IRDFLG.EQ.0) WRITE(IOUT,13)
!   13 FORMAT(/,10X,'DIVERSION SEGMENT NUMBER',10X,
!     1       'UPSTREAM SEGMENT NUMBER')
      DO 345 IK=1,NSS
      READ(IN,14) IDIVAR(IK)
   14 FORMAT(I10)
      WRITE(IOUT,*) 'IDIVAR(IK):'
      WRITE(IOUT,*) IDIVAR(IK)
!      IF(IRDFLG.EQ.0) WRITE(IOUT,15) IK,IDIVAR(IK)
!   15 FORMAT(19X,I6,27X,I6)
  345 CONTINUE
C
C11----SET FLOW OUT OF REACH, FLOW INTO REACH, AND FLOW THROUGH
C      STREAM BED TO ZERO.
  350 DO 360 II =1,NSTREM
      STRM(9,II)=0.0
      STRM(10,II)=0.0
      STRM(11,II)=0.0
  360 CONTINUE
C
C12------RETURN
      RETURN
      END
!      SUBROUTINE GWF2STR7FM(IGRID)
C     *****************************************************************C
C     ADD STREAM TERMS TO RHS AND HCOF IF FLOW OCCURS IN MODEL CELL    C
C     *****************************************************************C
!      SUBROUTINE GWF2STR7BD(KSTP,KPER,IGRID)
C     *****************************************************************C
C     CALCULATE VOLUMETRIC BUDGET FOR STREAMS                          C
C     *****************************************************************C
      SUBROUTINE SGWF2STR7R(NLST,MXSTRM,STRM,ISTRM,LSTBEG,IN,
     1          IOUT,NCOL,NROW,NLAY,IRDFLG)
C     *****************************************************************C
C     READ STRM AND ISTRM
C     *****************************************************************C
C
C     SPECIFICATIONS:
C     -----------------------------------------------------------------C
      DIMENSION STRM(11,MXSTRM),ISTRM(5,MXSTRM)
C     -----------------------------------------------------------------C
C
C5------READ AND PRINT DATA FOR EACH STREAM CELL.
!      IF(IRDFLG.EQ.0) WRITE(IOUT,4)
!    4 FORMAT(/,4X,'LAYER   ROW    COL    SEGMENT   REACH   STREAMFLOW',
!     16X,'STREAM    STREAMBED     STREAMBED BOT  STREAMBED TOP',/27X,
!     2'NUMBER   NUMBER                   STAGE   CONDUCTANCE',6X,
!     3'ELEVATION      ELEVATION',/3X,110('-'))
      N=NLST+LSTBEG-1
      DO 250 II=LSTBEG,N
      READ(IN,5)K,I,J,ISTRM(4,II),ISTRM(5,II),STRM(1,II),STRM(2,II),
     1STRM(3,II),STRM(4,II),STRM(5,II)
    5 FORMAT(5I5,F15.0,4F10.0)
      WRITE(IOUT,*)'K,I,J,ISTRM(4,II),ISTRM(5,II),STRM(1,II),STRM(2,II),
     1STRM(3,II),STRM(4,II),STRM(5,II):'
      WRITE(IOUT,*)K,I,J,ISTRM(4,II),ISTRM(5,II),STRM(1,II),STRM(2,II),
     1STRM(3,II),STRM(4,II),STRM(5,II)
      IF(IRDFLG.EQ.0) WRITE(IOUT,6)K,I,J,ISTRM(4,II),
     1ISTRM(5,II),STRM(1,II),STRM(2,II),STRM(3,II),STRM(4,II),STRM(5,II)
    6 FORMAT(1X,1X,I6,2I7,2I9,7X,G11.4,G12.4,G11.4,4X,2G13.4)
      ISTRM(1,II)=K
      ISTRM(2,II)=I
      ISTRM(3,II)=J
C
C  Check for illegal grid location
      IF(K.LT.1 .OR. K.GT.NLAY) THEN
         WRITE(IOUT,*) ' Layer number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
      IF(I.LT.1 .OR. I.GT.NROW) THEN
         WRITE(IOUT,*) ' Row number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
      IF(J.LT.1 .OR. J.GT.NCOL) THEN
         WRITE(IOUT,*) ' Column number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
  250 CONTINUE
C
      RETURN
      END
      SUBROUTINE GWF2STR7DA(IGRID)
C  Deallocate STR DATA
      USE GWFSTRMODULE
C
        DEALLOCATE(GWFSTRDAT(IGRID)%MXSTRM)
        DEALLOCATE(GWFSTRDAT(IGRID)%NSTREM)
        DEALLOCATE(GWFSTRDAT(IGRID)%NSS)
        DEALLOCATE(GWFSTRDAT(IGRID)%NTRIB)
        DEALLOCATE(GWFSTRDAT(IGRID)%NDIV)
        DEALLOCATE(GWFSTRDAT(IGRID)%ICALC)
        DEALLOCATE(GWFSTRDAT(IGRID)%ISTCB1)
        DEALLOCATE(GWFSTRDAT(IGRID)%ISTCB2)
        DEALLOCATE(GWFSTRDAT(IGRID)%IPTFLG)
        DEALLOCATE(GWFSTRDAT(IGRID)%CONST)
        DEALLOCATE(GWFSTRDAT(IGRID)%NPSTR)
        DEALLOCATE(GWFSTRDAT(IGRID)%ISTRPB)
        DEALLOCATE(GWFSTRDAT(IGRID)%STRM)
        DEALLOCATE(GWFSTRDAT(IGRID)%ARTRIB)
        DEALLOCATE(GWFSTRDAT(IGRID)%ISTRM)
        DEALLOCATE(GWFSTRDAT(IGRID)%ITRBAR)
        DEALLOCATE(GWFSTRDAT(IGRID)%IDIVAR)
        DEALLOCATE(GWFSTRDAT(IGRID)%NDFGAR)
C
      RETURN
      END
      SUBROUTINE SGWF2STR7PNT(IGRID)
C  Set pointers to STR data for grid.
      USE GWFSTRMODULE
C
        MXSTRM=>GWFSTRDAT(IGRID)%MXSTRM
        NSTREM=>GWFSTRDAT(IGRID)%NSTREM
        NSS=>GWFSTRDAT(IGRID)%NSS
        NTRIB=>GWFSTRDAT(IGRID)%NTRIB
        NDIV=>GWFSTRDAT(IGRID)%NDIV
        ICALC=>GWFSTRDAT(IGRID)%ICALC
        ISTCB1=>GWFSTRDAT(IGRID)%ISTCB1
        ISTCB2=>GWFSTRDAT(IGRID)%ISTCB2
        IPTFLG=>GWFSTRDAT(IGRID)%IPTFLG
        CONST=>GWFSTRDAT(IGRID)%CONST
        NPSTR=>GWFSTRDAT(IGRID)%NPSTR
        ISTRPB=>GWFSTRDAT(IGRID)%ISTRPB
        STRM=>GWFSTRDAT(IGRID)%STRM
        ARTRIB=>GWFSTRDAT(IGRID)%ARTRIB
        ISTRM=>GWFSTRDAT(IGRID)%ISTRM
        ITRBAR=>GWFSTRDAT(IGRID)%ITRBAR
        IDIVAR=>GWFSTRDAT(IGRID)%IDIVAR
        NDFGAR=>GWFSTRDAT(IGRID)%NDFGAR
C
      RETURN
      END
      SUBROUTINE SGWF2STR7PSV(IGRID)
C  Save pointers to STR data for grid.
      USE GWFSTRMODULE
C
        GWFSTRDAT(IGRID)%MXSTRM=>MXSTRM
        GWFSTRDAT(IGRID)%NSTREM=>NSTREM
        GWFSTRDAT(IGRID)%NSS=>NSS
        GWFSTRDAT(IGRID)%NTRIB=>NTRIB
        GWFSTRDAT(IGRID)%NDIV=>NDIV
        GWFSTRDAT(IGRID)%ICALC=>ICALC
        GWFSTRDAT(IGRID)%ISTCB1=>ISTCB1
        GWFSTRDAT(IGRID)%ISTCB2=>ISTCB2
        GWFSTRDAT(IGRID)%IPTFLG=>IPTFLG
        GWFSTRDAT(IGRID)%CONST=>CONST
        GWFSTRDAT(IGRID)%NPSTR=>NPSTR
        GWFSTRDAT(IGRID)%ISTRPB=>ISTRPB
        GWFSTRDAT(IGRID)%STRM=>STRM
        GWFSTRDAT(IGRID)%ARTRIB=>ARTRIB
        GWFSTRDAT(IGRID)%ISTRM=>ISTRM
        GWFSTRDAT(IGRID)%ITRBAR=>ITRBAR
        GWFSTRDAT(IGRID)%IDIVAR=>IDIVAR
        GWFSTRDAT(IGRID)%NDFGAR=>NDFGAR
C
      RETURN
      END
