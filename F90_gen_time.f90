        program gentime
                implicit none
                !Structure
                ! (1) enter start and end of simulation
                ! (2) enter calendar: 1 for 365 leap, 2 for 365 nonleap, 3 for 360
                ! (3) compute part of the filenames containing information about time
                ! (4) compute time steps       for each DM, MM and SM file
                ! (5) compute time step bounds for each DM, MM and SM file
                ! (6) save txt files for other programs

        real(kind=4) :: Sstart, Send
        integer      :: SstartY, SstartM, SstartD, SendY, SendM, SendD
        integer      :: SstartM_FirstSeason, SendM_LastSeason
        integer      :: caln, nDays
        integer      :: i,i2,j,k,l
        integer      :: filekMM, filekDM, filekSM
        integer      :: timeAxis, timeAxisStart, timeAxisEnd, pomocna1DM, pomocna2DM, pomocna1MM, pomocna2MM
        integer, external    :: numberOfDays, daysInMonth
        character(len=30)    :: filename

      print *, "Enter starting date of your simulation (YYYYMMDD):"
!     read  *, Sstart
      Sstart=19890101
      print *, "Enter final    date of your simulation (YYYYMMDD):"
!     read  *, Send
      Send=20081231
      print *, "Select calendar: (1) 365 leap, (2) 365 nonleap, (3) 360"
!     read  *, caln
      caln=1

        ! Compute time details (YEAR, MONTH, DAY)
        SstartY=floor(Sstart/10000)
        SstartM=floor((Sstart-SstartY*10000)/100)
        SstartD=Sstart-SstartY*10000-SstartM*100
        SendY  =floor(Send/10000)
        SendM  =floor((Send-SendY*10000)/100)
        SendD  =Send-SendY*10000-SendM*100
        ! Determine the last month of the last full season.
        if     ((SendM==12).or.(SendM==1))  then
             SendM_LastSeason=11
        elseif (SendM==2)                   then
             SendM_LastSeason=2
        elseif ((SendM==3).or.(SendM==4))   then
             SendM_LastSeason=2
        elseif (SendM==5)                   then
             SendM_LastSeason=5
        elseif ((SendM==6).or.(SendM==7))   then
             SendM_LastSeason=5
        elseif (SendM==8)                   then
             SendM_LastSeason=5
        elseif ((SendM==9).or.(SendM==10))  then
             SendM_LastSeason=8
        elseif (SendM==11)                  then
             SendM_LastSeason=11
        end if
        ! Determine the first month of the first full season <<< in case of very short simulations (<3months) this code should be modifed
        if     (SstartM==12)                    then
                SstartM_FirstSeason=12
        elseif ((SstartM==1).or.(SstartM==2))   then
                SstartM_FirstSeason=3
        elseif (SstartM==3)                     then
                SstartM_FirstSeason=3
        elseif ((SstartM==4).or.(SstartM==5))   then
                SstartM_FirstSeason=6
        elseif (SstartM==6)                     then
                SstartM_FirstSeason=6
        elseif ((SstartM==7).or.(SstartM==8))   then
                SstartM_FirstSeason=9
        elseif (SstartM==9)                     then
                SstartM_FirstSeason=9
        elseif ((SstartM==10).or.(SstartM==11)) then
                SstartM_FirstSeason=12
        end if


      ! Output is writen in following files
      open(unit=12, file="prepared_filenames_MM.txt", action="write",status="old",position="append")
      open(unit=13, file="prepared_filenames_DM.txt", action="write",status="old",position="append")
      open(unit=14, file="prepared_filenames_SM.txt", action="write",status="old",position="append")

        filekMM=1
        filekDM=1
        filekSM=1
        do i=SstartY,SendY
                !-----------------------------------------------------------------------------------
                !Start: determine the start of the time axis
                !-----------------------------------------------------------------------------------
                !>>> Referent time period for CORDEX (2013., 2014.) is
                !>>> 1949-12-01 T00:00:00Z
                !>>> Days from 1950-01-01 to current year
                timeAxis=0
                do i2=1950,i  
                   timeAxis=timeAxis+numberOfDays(caln,i2)
                enddo
                !>>> Add number of days in 1949-12
                if (caln==3) then
                   timeAxis=timeAxis+30
                else
                   timeAxis=timeAxis+31
                end if
                print *,timeAxis
 
                !-----------------------------------------------------------------------------------
                !End: determine the start of the time axis
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write MM filenames
                !-----------------------------------------------------------------------------------
                pomocna1MM=0
                pomocna2MM=0
                if (mod(i,10)==1) then                         ! start the 10yr filename
                        j=i+9
                        k=12
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
                                write(12,"(A,I3,A,I4,A,I4,I2)")    &
                                'filenameMM[',filekMM,']=_',i,'01-',j    ,k
                                filekMM=filekMM+1
                        else 
                                write(12,"(A,I3,A,I4,A,I4,A,I1)")  &
                                'filenameMM[',filekMM,']=_',i,'01-',j,'0',k
                                filekMM=filekMM+1
                        end if
                        pomocna1MM=i
                        pomocna2MM=j
                else                                           ! special case for the first year
                        if (i==SstartY) then                  
                                k=SstartM
                                j=i
                                do l=i,i+10
                                     if (mod(j,10)==0) then
                                     cycle
                                     end if
                                     j=j+1
                                end do
                                if (k>9) then
                                     write(12,"(A,I3,A,I4,I2,A,I4,A)")   &
                                     'filenameMM[',filekMM,']=_',i,k,'-',j        ,'12'
                                     filekMM=filekMM+1
                                else 
                                     write(12,"(A,I3,A,I4,A,I1,A,I4,A)") &
                                     'filenameMM[',filekMM,']=_',i,'0',k,'-',j    ,'12'
                                     filekMM=filekMM+1
                                end if
                                pomocna1MM=i
                                pomocna2MM=j
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write MM filenames
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start:   Write time axis for the MM filename. This works fine if first date is 1.1. (for now)
                !Advice:  use for testing e.g. http://www.wolframalpha.com/input/?i=days+from+1949-12-01+to+2008-12-31
                !-----------------------------------------------------------------------------------
                if (pomocna1MM>0) then
                !>>> Days from 1950-01-01 to current year
                        write(filename, "('prepared_time_MM',I1.1,'.txt')") filekMM-1
                        print *,filename
                        open(unit=24, file=filename, action="write",status="new",position="append")
	                timeAxisStart=0
        	        timeAxisEnd  =0

                !>>> Add number of days in 1949-12 + 1.1. of the first year
        	        if (caln==3) then
        	           timeAxisStart=timeAxisStart+30+1
        	           timeAxisEnd  =timeAxisEnd  +30
        	        else
        	           timeAxisStart=timeAxisStart+31+1
        	           timeAxisEnd  =timeAxisEnd  +31
        	        end if ! from caln

                !>>> Define beginning > find first day of first month > write always the 15th day of the month
	                do i2=1950,pomocna1MM-1               !-1 because we want to start with 1.1. 
        	           timeAxisStart=timeAxisStart+numberOfDays(caln,i2)
        	        enddo
        	        do i2=pomocna1MM,pomocna2MM
                           write(24,"(I8)"),timeAxisStart+15
        	           timeAxisStart=timeAxisStart+numberOfDays(caln,i2)
        	        enddo
                        close(unit=24)
                end if ! from pomocna1MM
                !-----------------------------------------------------------------------------------
                !End:   Write time axis for the MM filename
                !-----------------------------------------------------------------------------------

                !-----------------------------------------------------------------------------------
                !Start: Write DM filenames
                !-----------------------------------------------------------------------------------
                pomocna1DM=0
                pomocna2DM=0
                if (mod(i,5)==1) then                    ! start 5yr filenames
                        j=i+4
                        k=12
                        if (j>=SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
             write(13,"(A,I3,A,I4,A,I4,I2,I2)")   & 
             'filenameDM[',filekDM,']=_',i,'0101-', j,    k,daysInMonth(caln,k)
                        filekDM=filekDM+1
                        else 
             write(13,"(A,I3,A,I4,A,I4,A,I1,I2)") & 
             'filenameDM[',filekDM,']=_',i,'0101-',j,'0', k,daysInMonth(caln,k)
                        filekDM=filekDM+1
                        end if
                        pomocna1DM=i
                        pomocna2DM=j
                else                                     ! special case for the first year
                        if (i==SstartY) then
                                k=SstartM
                                j=i
                                do l=i,i+5
                                        if (mod(j,5)==0) then
                                        cycle
                                        end if
                                        j=j+1
                                end do
                        if (k>9) then
             write(13,"(A,I3,A,I4,I2,A,I4,A,I2)")  & 
             'filenameDM[',filekDM,']=_',i,k,'01-',j,'12',daysInMonth(caln,12)
                        filekDM=filekDM+1
                        pomocna1DM=i
                        pomocna2DM=j
                        else 
             write(13,"(A,I3,A,I4,A,I1,A,I4,A,I2)") &
             'filenameDM[',filekDM,']=_',i,'0',k,'01-',j,'12',daysInMonth(caln,12)
                        filekDM=filekDM+1
                        pomocna1DM=i
                        pomocna2DM=j
                        end if
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write DM filenames
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start:   Write time axis for the DM filename. This works fine if first date is 1.1. (for now)
                !Advice:  use for testing e.g. http://www.wolframalpha.com/input/?i=days+from+1949-12-01+to+2008-12-31
                !-----------------------------------------------------------------------------------
                if (pomocna1DM>0) then
                !>>> Days from 1950-01-01 to current year
                        write(filename, "('prepared_time_DM',I1.1,'.txt')") filekDM-1
                        print *,filename
                        open(unit=23, file=filename, action="write",status="new",position="append")
	                timeAxisStart=0
        	        timeAxisEnd  =0
	                do i2=1950,pomocna1DM-1               !-1 because we want to start with 1.1. 
        	           timeAxisStart=timeAxisStart+numberOfDays(caln,i2)
        	        enddo
        	        do i2=1950,pomocna2DM
        	           timeAxisEnd  =timeAxisEnd  +numberOfDays(caln,i2)
        	        enddo
                !>>> Add number of days in 1949-12 + 1.1. of the first year
        	        if (caln==3) then
        	           timeAxisStart=timeAxisStart+30+1
        	           timeAxisEnd  =timeAxisEnd  +30
        	        else
        	           timeAxisStart=timeAxisStart+31+1
        	           timeAxisEnd  =timeAxisEnd  +31
        	        end if
                !>>> Writing days from timeAxisStart to timeAxisEnd
        	        do i2=timeAxisStart,timeAxisEnd
                           write(23,"(I8)"),i2
                        end do	
                        close(unit=23)
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write time axis for the DM filename
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write SM filenames
                !-----------------------------------------------------------------------------------
                if (i==SstartY) then                        ! special case for the first year
                                k=SstartM_FirstSeason
                                j=i
                                do l=i,i+10
                                        if (mod(j,10)==0) then
                                        cycle
                                        end if
                                        j=j+1
                                end do
                        if (k>9) then
                                write(14,"(A,I3,A,I4,I2,A,I4,A)")     &
                                'filenameSM[',filekSM,']=_',i,k,'-',j        ,'11'
                                filekSM=filekSM+1
                        else 
                                write(14,"(A,I3,A,I4,A,I1,A,I4,A)")  & 
                                'filenameSM[',filekSM,']=_',i,'0',k,'-',j    ,'11'
                                filekSM=filekSM+1
                        end if
                endif
                if (mod(i,10)==0) then                     ! start the 10yr filaneme
                        j=i+10
                        k=11
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM_LastSeason
                        end if
                        if (k>9) then
                                write(14,"(A,I3,A,I4,A,I4,I2)")   & 
                                'filenameSM[',filekSM,']=_',i,'12-',j    ,k
                                filekSM=filekSM+1
                        else 
                                write(14,"(A,I3,A,I4,A,I4,A,I1)") &
                                'filenameSM[',filekSM,']=_',i,'12-',j,'0',k
                                filekSM=filekSM+1
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write SM filenames
                !-----------------------------------------------------------------------------------
        end do !i years

        ! Close all output files
        close(unit=12)
        close(unit=13)
        close(unit=14)

        end program gentime
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
        integer function numberOfDays(caln,i)
                implicit none
                integer,intent(in)       :: caln,i
                integer,dimension(1:12)  :: daysInMonth
                integer                  :: nDays

                !-----------------------------------------------------------------------------------
                !Start: determine number of days in specific year
                !-----------------------------------------------------------------------------------
                ! 365 day leap calendar
                if      (caln==1) then
                        nDays=365
                        daysInMonth=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                        if (mod(i,4)==0) then
                                if (mod(i,100)==0) then
                                        if (mod(i,400)==0) then
                                                nDays=366
                                                daysInMonth=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                                        else
                                                nDays=365
                                                daysInMonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)
                                        end if
                                else
                                        nDays=366
                                        daysInMonth=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                                end if
                        end if
                ! 365 day noleap calendar
                else if (caln==2) then
                        nDays=365
                        daysInMonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)
                ! 360 day calendar
                else if (caln==3) then
                        nDays=360
                        daysInMonth=(/30,30,30,30,30,30,30,30,30,30,30,30/)
                end if

                numberOfDays=nDays
                !-----------------------------------------------------------------------------------
                !End: determine number of days in specific year
                !-----------------------------------------------------------------------------------
          end function numberOfDays
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------
         integer function daysInMonth(caln,i)
                implicit none
                integer,intent(in)       :: caln,i  ! (1) calendar, (2) month in year
                integer,dimension(1:12)  :: days

                !-----------------------------------------------------------------------------------
                !Start: set the number of days in specific month 
                !-----------------------------------------------------------------------------------
                ! 365 day leap calendar
                if      (caln==1) then
                        days=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                        if (mod(i,4)==0) then
                                if (mod(i,100)==0) then
                                        if (mod(i,400)==0) then
                                              days=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                                        else
                                              days=(/31,28,31,30,31,30,31,31,30,31,30,31/)
                                        end if
                                else
                                              days=(/31,29,31,30,31,30,31,31,30,31,30,31/)
                                end if
                        end if
                ! 365 day noleap calendar
                else if (caln==2) then
                        days=(/31,28,31,30,31,30,31,31,30,31,30,31/)
                ! 360 day calendar
                else if (caln==3) then
                        days=(/30,30,30,30,30,30,30,30,30,30,30,30/)
                end if
               
                daysInMonth=days(i)
                !-----------------------------------------------------------------------------------
                !End: set the number of days in specific year
                !-----------------------------------------------------------------------------------
         end function  daysInMonth
