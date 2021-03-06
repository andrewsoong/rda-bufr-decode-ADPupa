      SUBROUTINE DRSTPL(INOD,LUN,INV1,INV2,INVN)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    DRSTPL 
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS SUBROUTINE IS CALLED BY BUFR ARCHIVE LIBRARY SUBROUTINE
C   UFBRW WHENEVER IT CAN'T FIND A MNEMONIC IT WANTS TO WRITE WITHIN THE
C   CURRENT SUBSET BUFFER.  IT LOOKS FOR THE MNEMONIC WITHIN ANY
C   UNEXPANDED "DRS" (STACK) OR "DRB" (1-BIT DELAYED REPLICATION)
C   SEQUENCES INSIDE OF THE PORTION OF THE SUBSET BUFFER BOUNDED BY THE
C   INDICES INV1 AND INV2.  IF FOUND, IT EXPANDS THE APPLICABLE "DRS" OR
C   "DRB" SEQUENCE TO THE POINT WHERE THE MNEMONIC IN QUESTION NOW
C   APPEARS IN THE SUBSET BUFFER, AND IN DOING SO IT WILL ALSO RETURN
C   A NEW VALUE FOR INV2.
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C                           ROUTINE "BORT" (LATER REMOVED, UNKNOWN
C                           WHEN)
C 2002-05-14  J. WOOLLEN -- REMOVED OLD CRAY COMPILER DIRECTIVES
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C                           INCREASED FROM 15000 TO 16000 (WAS IN
C                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C                           WRF; ADDED DOCUMENTATION (INCLUDING
C                           HISTORY) 
C 2009-03-31  J. WOOLLEN -- ADDED ADDITIONAL DOCUMENTATION
C
C USAGE:    CALL DRSTPL (INOD, LUN, INV1, INV2, INVN)
C
C   INPUT ARGUMENT LIST:
C     INOD     - INTEGER: JUMP/LINK TABLE INDEX OF MNEMONIC TO LOOK FOR 
C     LUN      - INTEGER: I/O STREAM INDEX INTO INTERNAL MEMORY ARRAYS
C     INV1     - INTEGER: STARTING INDEX OF THE PORTION OF THE SUBSET
C                BUFFER CURRENTLY BEING PROCESSED BY UFBRW
C     INV2     - INTEGER: ENDING INDEX OF THE PORTION OF THE SUBSET
C                BUFFER CURRENTLY BEING PROCESSED BY UFBRW
C
C   OUTPUT ARGUMENT LIST:
C     INVN     - INTEGER: LOCATION INDEX OF INOD WITHIN SUBSET BUFFER:
C                  0 = NOT FOUND
C     INV2     - INTEGER: IF INVN = 0, THEN INV2 IS UNCHANGED FROM ITS
C                INPUT VALUE.  OTHERWISE, IT CONTAINS THE REDEFINED
C                ENDING INDEX OF THE PORTION OF THE SUBSET BUFFER
C                CURRENTLY BEING PROCESSED BY UFBRW, SINCE EXPANDING A
C                DELAYED REPLICATION SEQUENCE WILL HAVE NECESSARILY
C                INCREASED THE SIZE OF THIS BUFFER.
C
C REMARKS:
C    THIS ROUTINE CALLS:        INVWIN   NEWWIN   USRTPL
C    THIS ROUTINE IS CALLED BY: UFBRW
C                               Normally not called by any application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      COMMON /TABLES/ MAXTAB,NTAB,TAG(MAXJL),TYP(MAXJL),KNT(MAXJL),
     .                JUMP(MAXJL),LINK(MAXJL),JMPB(MAXJL),
     .                IBT(MAXJL),IRF(MAXJL),ISC(MAXJL),
     .                ITP(MAXJL),VALI(MAXJL),KNTI(MAXJL),
     .                ISEQ(MAXJL,2),JSEQ(MAXJL)

      CHARACTER*10 TAG
      CHARACTER*3  TYP

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

1     NODE = INOD
2     NODE = JMPB(NODE)
      IF(NODE.EQ.0) GOTO 100
      IF(TYP(NODE).EQ.'DRS' .OR. TYP(NODE).EQ.'DRB') THEN
         INVN = INVWIN(NODE,LUN,INV1,INV2)
         IF(INVN.GT.0) THEN
            CALL USRTPL(LUN,INVN,1)
            CALL NEWWIN(LUN,INV1,INV2)
            INVN = INVWIN(INOD,LUN,INVN,INV2)
            IF(INVN.GT.0) GOTO 100
            GOTO 1
         ENDIF
      ENDIF
      GOTO 2

C  EXIT
C  ----

100   RETURN
      END
