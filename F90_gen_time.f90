	program gentime
		implicit none
		!Structure
		! (1) enter start and end of simulation
		! (2) enter calendar 1 365 leap, 2 365 nonleap, 3 360
		! (3) compute time steps       for each DM, MM and SM file
		! (4) compute time step bounds for each DM, MM and SM file
		! (5) save txt files for othe programs

	integer :: Sstart, Send
	integer :: SstartY, SstartM, SstartD, SendY, SendM, SendD

	print *,"Enter starting date of your simulation (YYYYMMDD):"
	read *, Sstart
	print *,"Enter final    date of your simulation (YYYYMMDD):"
	read *, Send
	! Compute details
	SstartY=floor(Sstart/10000)
	SstartM=floor((Sstart-SstartY)/100)
	SstartD=Sstart-SstartY-SstartM

	!Check
	print *,"Year : ",SstartY
	print *,"Month: ",SstartM
	print *,"Day  : ",SstartD



	end program gentime
