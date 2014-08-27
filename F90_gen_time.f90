        program gentime
                implicit none
                !Structure
                ! (1) enter start and end of simulation
                ! (2) enter calendar 1 365 leap, 2 365 nonleap, 3 360
                ! (3) compute time steps       for each DM, MM and SM file
                ! (4) compute time step bounds for each DM, MM and SM file
                ! (5) save txt files for other programs

        real(kind=4) :: Sstart, Send
        integer      :: SstartY, SstartM, SstartD, SendY, SendM, SendD, SendM_LastSeason
        integer      :: caln, nDays
        integer      :: i,j,k,l
        integer      :: filekMM, filekDM, filekSM
        integer,dimension(1:12)  :: daysInMonth

      print *, "Enter starting date of your simulation (YYYYMMDD):"
!     read  *, Sstart
      Sstart=19700101
      print *, "Enter final    date of your simulation (YYYYMMDD):"
!     read  *, Send
      Send=20051130
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
        ! Determine the last month of the last full season
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


      ! Output is writen in following files
      open(unit=12, file="filenames_MM.txt", action="write",status="old",position="append")
      open(unit=13, file="filenames_DM.txt", action="write",status="old",position="append")
      open(unit=14, file="filenames_SM.txt", action="write",status="old",position="append")

        filekMM=1
        filekDM=1
        filekSM=1
        do i=SstartY,SendY
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
                !-----------------------------------------------------------------------------------
                !End: determine number of days in specific year
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write MM filenames
                !-----------------------------------------------------------------------------------
                if (mod(i,10)==1) then
                        j=i+9
                        k=12
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
                                write(12,"(A,I3,A,I4,A,I4,I2)")   'filenameMM[',filekMM,']=_',i,'01-',j    ,k
                                filekMM=filekMM+1
                        else 
                                write(12,"(A,I3,A,I4,A,I4,A,I1)") 'filenameMM[',filekMM,']=_',i,'01-',j,'0',k
                                filekMM=filekMM+1
                        end if
                else
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
                                write(12,"(A,I3,A,I4,I2,A,I4,A)")    'filenameMM[',filekMM,']=_',i,k,'-',j        ,'12'
                                filekMM=filekMM+1
                        else 
                                write(12,"(A,I3,A,I4,A,I1,A,I4,A)")  'filenameMM[',filekMM,']=_',i,'0',k,'-',j    ,'12'
                                filekMM=filekMM+1
                        end if
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write MM filenames
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write DM filenames
                !-----------------------------------------------------------------------------------
                if (mod(i,5)==1) then
                        j=i+4
                        k=12
                        if (j>=SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
             write(13,"(A,I3,A,I4,A,I2,A,I4,I2,I2)")   'filenameDM[',filekDM,']=_',i,'01',daysInMonth(1),'-',j,k,daysInMonth(k)
                        filekDM=filekDM+1
                        else 
             write(13,"(A,I3,A,I4,A,I2,A,I4,A,I1,I2)") 'filenameDM[',filekDM,']=_',i,'01',daysInMonth(1),'-',j,'0',k,daysInMonth(k)
                        filekDM=filekDM+1
                        end if
                else
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
             write(13,"(A,I3,A,I4,I2,I2,A,I4,A,I2)")   'filenameDM[',filekDM,']=_',i,k,daysInMonth(k),'-',j,'12',daysInMonth(12)
                        filekDM=filekDM+1
                        else 
             write(13,"(A,I3,A,I4,A,I1,I2,A,I4,A,I2)") 'filenameDM[',filekDM,']=_',i,'0',k,daysInMonth(k),'-',j,'12',daysInMonth(12)
                        filekDM=filekDM+1
                        end if
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write DM filenames
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write SM filenames
                !-----------------------------------------------------------------------------------
                if (mod(i,10)==0) then
                        j=i+10
                        k=11
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM_LastSeason
                        end if
                        if (k>9) then
                                write(14,"(A,I3,A,I4,A,I4,I2)")   'filenameSM[',filekSM,']=_',i,'12-',j    ,k
                                filekSM=filekSM+1
                        else 
                                write(14,"(A,I3,A,I4,A,I4,A,I1)") 'filenameSM[',filekSM,']=_',i,'12-',j,'0',k
                                filekSM=filekSM+1
                        end if
!                else
!                        if (i==SstartY) then
!                                k=SstartM
!                                j=i
!                                do l=i,i+10
!                                        if (mod(j,10)==0) then
!                                        cycle
!                                        end if
!                                        j=j+1
!                                end do
!                        if (k>9) then
!                                write(14,"(A,I3,A,I4,I2,A,I4,A)")    'filenameSM[',filekSM,']=_',i,k,'-',j        ,'12'
!                                filekSM=filekSM+1
!                        else 
!                                write(14,"(A,I3,A,I4,A,I1,A,I4,A)")  'filenameSM[',filekSM,']=_',i,'0',k,'-',j    ,'12'
!                                filekSM=filekSM+1
!                        end if
!                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End:   Write SM filenames
                !-----------------------------------------------------------------------------------
        end do !i years

        close(unit=12)
        close(unit=13)
        close(unit=14)

        end program gentime
