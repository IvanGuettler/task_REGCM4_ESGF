        program gentime
                implicit none
                !Structure
                ! (1) enter start and end of simulation
                ! (2) enter calendar 1 365 leap, 2 365 nonleap, 3 360
                ! (3) compute time steps       for each DM, MM and SM file
                ! (4) compute time step bounds for each DM, MM and SM file
                ! (5) save txt files for othe programs

        real(kind=4) :: Sstart, Send
        integer      :: SstartY, SstartM, SstartD, SendY, SendM, SendD
        integer      :: caln, nDays
        integer      :: i,j,k,l
        integer      :: filekMM, filekDM

        print *, "Enter starting date of your simulation (YYYYMMDD):"
!       read  *, Sstart
        Sstart=19700101
        print *, "Enter final    date of your simulation (YYYYMMDD):"
!       read  *, Send
        Send=20051130
      print *, "Select calendar: (1) 365 leap, (2) 365 nonleap, (3) 360"
!       read  *, caln
        caln=1

        ! Compute details
        SstartY=floor(Sstart/10000)
        SstartM=floor((Sstart-SstartY*10000)/100)
        SstartD=Sstart-SstartY*10000-SstartM*100
        SendY  =floor(Send/10000)
        SendM  =floor((Send-SendY*10000)/100)
        SendD  =Send-SendY*10000-SendM*100

      open(unit=12, file="filenames_MM.txt", action="write",status="old",position="append")
      open(unit=13, file="filenames_DM.txt", action="write",status="old",position="append")

        filekMM=1
        filekDM=1
        do i=SstartY,SendY
                !-----------------------------------------------------------------------------------
                !Start: determine number of days in specific year
                !-----------------------------------------------------------------------------------
                ! 365 day leap calendar
                if      (caln==1) then
                        nDays=365
                        if (mod(i,4)==0) then
                                if (mod(i,100)==0) then
                                        if (mod(i,400)==0) then
                                                nDays=366
                                        else
                                                nDays=365
                                        end if
                                else
                                        nDays=366
                                end if
                        end if
                ! 365 day noleap calendar
                else if (caln==2) then
                        nDays=365
                ! 360 day calendar
                else if (caln==3) then
                        nDays=360
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
                !End: Write MM filenames
                !-----------------------------------------------------------------------------------
                !-----------------------------------------------------------------------------------
                !Start: Write DM filenames
                !-----------------------------------------------------------------------------------
                if (mod(i,5)==1) then
                        j=i+4
                        k=12
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
                                write(13,"(A,I3,A,I4,A,I4,I2)")   'filenameDM[',filekDM,']=_',i,'01-',j    ,k
                                filekDM=filekDM+1
                        else 
                                write(13,"(A,I3,A,I4,A,I4,A,I1)")  'filenameDM[',filekDM,']=_',i,'01-',j,'0',k
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
                                write(13,"(A,I3,A,I4,I2,A,I4,A)")    'filenameDM[',filekDM,']=_',i,k,'-',j        ,'12'
                                filekDM=filekDM+1
                        else 
                                write(13,"(A,I3,A,I4,A,I1,A,I4,A)")  'filenameDM[',filekDM,']=_',i,'0',k,'-',j    ,'12'
                                filekDM=filekDM+1
                        end if
                        end if
                end if
                !-----------------------------------------------------------------------------------
                !End: Write DM filenames
                !-----------------------------------------------------------------------------------
        end do !i

        close(unit=12)
        close(unit=13)

        end program gentime
