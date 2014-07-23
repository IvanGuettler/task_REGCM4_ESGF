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

	print *, "Enter starting date of your simulation (YYYYMMDD):"
!	read  *, Sstart
	Sstart=19890101
	print *, "Enter final    date of your simulation (YYYYMMDD):"
!	read  *, Send
	Send=20090401
	print *, "Select calendar: (1) 365 leap, (2) 365 nonleap, (3) 360"
!	read  *, caln
	caln=1

	! Compute details
	SstartY=floor(Sstart/10000)
	SstartM=floor((Sstart-SstartY*10000)/100)
	SstartD=Sstart-SstartY*10000-SstartM*100
	SendY  =floor(Send/10000)
	SendM  =floor((Send-SendY*10000)/100)
	SendD  =Send-SendY*10000-SendM*100

        open(unit=12, file="filenames_MM.txt", action="write",status="old",position="append")

	do i=SstartY,SendY
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
		!Start Write MM filenames
		!-----------------------------------------------------------------------------------
		if (mod(i,10)==1) then
                        j=i+9
                        k=12
                        if (j>SendY) then 
                            j=SendY 
                            k=SendM
                        end if
                        if (k>9) then
			        write(12,"(A,I4,A,I4,I2)")   '_',i,'01-',j    ,k
                        else 
			        write(12,"(A,I4,A,I4,A,I1)") '_',i,'01-',j,'0',k
                        end if
		else
			if (i==SstartY) then
                                k=SstartM
                                j=i
				do l=i,i+10
                                        j=j+1
					if (mod(j,10)==0) then
					exit
                                        end if
				end do
                        if (k>9) then
			        write(12,"(A,I4,I2,A,I4,A)")     '_',i,k,'-',j        ,'12'
                        else 
			        write(12,"(A,I4,A,I1,A,I4,A)")   '_',i,'0',k,'-',j    ,'12'
                        end if
			end if
		end if
		!-----------------------------------------------------------------------------------
		!End Write MM filenames
		!-----------------------------------------------------------------------------------

	end do !i

        close(unit=12)

	end program gentime
