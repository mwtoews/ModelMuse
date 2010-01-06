      MODULE GWFWELMODULE
        INTEGER,SAVE,POINTER  ::NWELLS,MXWELL,NWELVL,IWELCB,IPRWEL
        INTEGER,SAVE,POINTER  ::NPWEL,IWELPB,NNPWEL
        CHARACTER(LEN=16),SAVE, DIMENSION(:),   POINTER     ::WELAUX
        REAL,             SAVE, DIMENSION(:,:), POINTER     ::WELL
      TYPE GWFWELTYPE
        INTEGER,POINTER  ::NWELLS,MXWELL,NWELVL,IWELCB,IPRWEL
        INTEGER,POINTER  ::NPWEL,IWELPB,NNPWEL
        CHARACTER(LEN=16), DIMENSION(:),   POINTER     ::WELAUX
        REAL,              DIMENSION(:,:), POINTER     ::WELL
      END TYPE
      TYPE(GWFWELTYPE), SAVE:: GWFWELDAT(10)
      END MODULE GWFWELMODULE


      SUBROUTINE GWF2WEL7AR(IN,IGRID)
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR WELL PACKAGE
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFWELMODULE, ONLY:NWELLS,MXWELL,NWELVL,IWELCB,IPRWEL,NPWEL,
     1                       IWELPB,NNPWEL,WELAUX,WELL
C
      CHARACTER*200 LINE
C     ------------------------------------------------------------------
      ALLOCATE(NWELLS,MXWELL,NWELVL,IWELCB,IPRWEL)
      ALLOCATE(NPWEL,IWELPB,NNPWEL)
C
C1------IDENTIFY PACKAGE AND INITIALIZE NWELLS.
      WRITE(IOUT,*)'WEL:'
!      WRITE(IOUT,1)IN
!    1 FORMAT(1X,/1X,'WEL -- WELL PACKAGE, VERSION 7, 5/2/2005',
!     1' INPUT READ FROM UNIT ',I4)
      NWELLS=0
      NNPWEL=0
C
C2------READ MAXIMUM NUMBER OF WELLS AND UNIT OR FLAG FOR
C2------CELL-BY-CELL FLOW TERMS.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPWEL,MXPW)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(2I10)') MXACTW,IWELCB
         LLOC=21
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXACTW,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IWELCB,R,IOUT,IN)
      END IF
      WRITE(IOUT,*) 'MXACTW, IWELCB:'
      WRITE(IOUT,*) MXACTW, IWELCB
!      WRITE(IOUT,3) MXACTW
!    3 FORMAT(1X,'MAXIMUM OF ',I6,' ACTIVE WELLS AT ONE TIME')
!      IF(IWELCB.LT.0) WRITE(IOUT,7)
!    7 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
!      IF(IWELCB.GT.0) WRITE(IOUT,8) IWELCB
!    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT ',I4)
C
C3------READ AUXILIARY VARIABLES AND PRINT FLAG.
      ALLOCATE(WELAUX(20))
      NAUX=0
      IPRWEL=1
   10 CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'AUXILIARY' .OR.
     1        LINE(ISTART:ISTOP).EQ.'AUX') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
         IF(NAUX.LT.20) THEN
            NAUX=NAUX+1
            WELAUX(NAUX)=LINE(ISTART:ISTOP)
            WRITE(IOUT,*) 'WELAUX(NAUX):'
            WRITE(IOUT,*) WELAUX(NAUX)
!   12       FORMAT(1X,'AUXILIARY WELL VARIABLE: ',A)
         END IF
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'NOPRINT') THEN
         WRITE(IOUT,*) 'NOPRINT:'
!         WRITE(IOUT,13)
!   13    FORMAT(1X,'LISTS OF WELL CELLS WILL NOT BE PRINTED')
         IPRWEL = 0
         GO TO 10
      END IF
C3A-----THERE ARE FOUR INPUT VALUES PLUS ONE LOCATION FOR
C3A-----CELL-BY-CELL FLOW.
      NWELVL=5+NAUX
C
C4------ALLOCATE SPACE FOR THE WELL DATA.
      IWELPB=MXACTW+1
      MXWELL=MXACTW+MXPW
      IF(MXACTW.LT.1) THEN
         WRITE(IOUT,17)
   17    FORMAT(1X,
     1'Deactivating the Well Package because MXACTW=0')
         IN=0
      END IF
      ALLOCATE (WELL(NWELVL,MXWELL))
C
C5------READ NAMED PARAMETERS.
!      WRITE(IOUT,18) NPWEL
!   18 FORMAT(1X,//1X,I5,' Well parameters')
      IF(NPWEL.GT.0) THEN
        LSTSUM=IWELPB
        DO 120 K=1,NPWEL
          LSTBEG=LSTSUM
          CALL UPARLSTRP(LSTSUM,MXWELL,IN,IOUT,IP,'WEL','Q',1,
     &                   NUMINST)
          NLST=LSTSUM-LSTBEG
          IF(NUMINST.EQ.0) THEN
C5A-----READ PARAMETER WITHOUT INSTANCES.
            WRITE(IOUT,*) 'Layer Row Column Qfact [xyz]:' 
            CALL ULSTRD(NLST,WELL,LSTBEG,NWELVL,MXWELL,1,IN,
     &        IOUT,'WELL NO.  LAYER   ROW   COL   STRESS FACTOR',
     &        WELAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,4,4,IPRWEL)
          ELSE
C5B-----READ INSTANCES.
            NINLST=NLST/NUMINST
            DO 110 I=1,NUMINST
            CALL UINSRP(I,IN,IOUT,IP,IPRWEL)
            WRITE(IOUT,*) 'Layer Row Column Qfact [xyz]:' 
            CALL ULSTRD(NINLST,WELL,LSTBEG,NWELVL,MXWELL,1,IN,
     &        IOUT,'WELL NO.  LAYER   ROW   COL   STRESS FACTOR',
     &        WELAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,4,4,IPRWEL)
            LSTBEG=LSTBEG+NINLST
  110       CONTINUE
          END IF
  120   CONTINUE
      END IF
C
C6------RETURN
      CALL SGWF2WEL7PSV(IGRID)
      RETURN
      END
      SUBROUTINE GWF2WEL7RP(IN,IGRID)
C     ******************************************************************
C     READ WELL DATA FOR A STRESS PERIOD
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GLOBAL,       ONLY:IOUT,NCOL,NROW,NLAY,IFREFM
      USE GWFWELMODULE, ONLY:NWELLS,MXWELL,NWELVL,IPRWEL,NPWEL,
     1                       IWELPB,NNPWEL,WELAUX,WELL
C
      CHARACTER*6 CWELL
C     ------------------------------------------------------------------
      WRITE(IOUT,*) 'WEL:' 
      CALL SGWF2WEL7PNT(IGRID)
C
C1----READ NUMBER OF WELLS (OR FLAG SAYING REUSE WELL DATA).
C1----AND NUMBER OF PARAMETERS
      IF(NPWEL.GT.0) THEN
        IF(IFREFM.EQ.0) THEN
           READ(IN,'(2I10)') ITMP,NP
        ELSE
           READ(IN,*) ITMP,NP
        END IF
        WRITE(IOUT,*) 'ITMP,NP:'
        WRITE(IOUT,*) ITMP,NP
      ELSE
         NP=0
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(I10)') ITMP
         ELSE
            READ(IN,*) ITMP
         END IF
        WRITE(IOUT,*) 'ITMP:'
        WRITE(IOUT,*) ITMP
      END IF
C
C------Calculate some constants.
      NAUX=NWELVL-5
      IOUTU = IOUT
      IF (IPRWEL.EQ.0) IOUTU=-IOUTU
C
C1A-----IF ITMP LESS THAN ZERO REUSE NON-PARAMETER DATA. PRINT MESSAGE.
C1A-----IF ITMP=>0, SET NUMBER OF NON-PARAMETER WELLS EQUAL TO ITMP.
      IF(ITMP.LT.0) THEN
!         WRITE(IOUT,6)
!    6    FORMAT(1X,/
!     1    1X,'REUSING NON-PARAMETER WELLS FROM LAST STRESS PERIOD')
      ELSE
         NNPWEL=ITMP
      END IF
C
C1B-----IF THERE ARE NEW NON-PARAMETER WELLS, READ THEM.
      MXACTW=IWELPB-1
      IF(ITMP.GT.0) THEN
         IF(NNPWEL.GT.MXACTW) THEN
            WRITE(IOUT,99) NNPWEL,MXACTW
   99       FORMAT(1X,/1X,'THE NUMBER OF ACTIVE WELLS (',I6,
     1                     ') IS GREATER THAN MXACTW(',I6,')')
            CALL USTOP(' ')
         END IF
	   WRITE(IOUT,*) 'Layer Row Column Q [xyz]:'
         CALL ULSTRD(NNPWEL,WELL,1,NWELVL,MXWELL,1,IN,IOUT,
     1            'WELL NO.  LAYER   ROW   COL   STRESS RATE',
     2             WELAUX,20,NAUX,IFREFM,NCOL,NROW,NLAY,4,4,IPRWEL)
      END IF
      NWELLS=NNPWEL
C
C1C-----IF THERE ARE ACTIVE WELL PARAMETERS, READ THEM AND SUBSTITUTE
      CALL PRESET('Q')
      NREAD=NWELVL-1
      IF(NP.GT.0) THEN
         DO 30 N=1,NP
         CALL UPARLSTSUB(IN,'WEL',IOUTU,'Q',WELL,NWELVL,MXWELL,NREAD,
     1                MXACTW,NWELLS,4,4,
     2            'WELL NO.  LAYER   ROW   COL   STRESS RATE',
     3            WELAUX,20,NAUX)
   30    CONTINUE
      END IF
C
C3------PRINT NUMBER OF WELLS IN CURRENT STRESS PERIOD.
      CWELL=' WELLS'
      IF(NWELLS.EQ.1) CWELL=' WELL '
!      WRITE(IOUT,101) NWELLS,CWELL
!  101 FORMAT(1X,/1X,I6,A)
C
C6------RETURN
      RETURN
      END
!      SUBROUTINE GWF2WEL7FM(IGRID)
C     ******************************************************************
C     SUBTRACT Q FROM RHS
C     ******************************************************************
!      SUBROUTINE GWF2WEL7BD(KSTP,KPER,IGRID)
C     ******************************************************************
C     CALCULATE VOLUMETRIC BUDGET FOR WELLS
C     ******************************************************************
      SUBROUTINE GWF2WEL7DA(IGRID)
C  Deallocate WEL MEMORY
      USE GWFWELMODULE
C
        CALL SGWF2WEL7PNT(IGRID)
        DEALLOCATE(NWELLS)
        DEALLOCATE(MXWELL)
        DEALLOCATE(NWELVL)
        DEALLOCATE(IWELCB)
        DEALLOCATE(IPRWEL)
        DEALLOCATE(NPWEL)
        DEALLOCATE(IWELPB)
        DEALLOCATE(NNPWEL)
        DEALLOCATE(WELAUX)
        DEALLOCATE(WELL)
C
      RETURN
      END
      SUBROUTINE SGWF2WEL7PNT(IGRID)
C  Change WEL data to a different grid.
      USE GWFWELMODULE
C
        NWELLS=>GWFWELDAT(IGRID)%NWELLS
        MXWELL=>GWFWELDAT(IGRID)%MXWELL
        NWELVL=>GWFWELDAT(IGRID)%NWELVL
        IWELCB=>GWFWELDAT(IGRID)%IWELCB
        IPRWEL=>GWFWELDAT(IGRID)%IPRWEL
        NPWEL=>GWFWELDAT(IGRID)%NPWEL
        IWELPB=>GWFWELDAT(IGRID)%IWELPB
        NNPWEL=>GWFWELDAT(IGRID)%NNPWEL
        WELAUX=>GWFWELDAT(IGRID)%WELAUX
        WELL=>GWFWELDAT(IGRID)%WELL
C
      RETURN
      END
      SUBROUTINE SGWF2WEL7PSV(IGRID)
C  Save WEL data for a grid.
      USE GWFWELMODULE
C
        GWFWELDAT(IGRID)%NWELLS=>NWELLS
        GWFWELDAT(IGRID)%MXWELL=>MXWELL
        GWFWELDAT(IGRID)%NWELVL=>NWELVL
        GWFWELDAT(IGRID)%IWELCB=>IWELCB
        GWFWELDAT(IGRID)%IPRWEL=>IPRWEL
        GWFWELDAT(IGRID)%NPWEL=>NPWEL
        GWFWELDAT(IGRID)%IWELPB=>IWELPB
        GWFWELDAT(IGRID)%NNPWEL=>NNPWEL
        GWFWELDAT(IGRID)%WELAUX=>WELAUX
        GWFWELDAT(IGRID)%WELL=>WELL
C
      RETURN
      END
