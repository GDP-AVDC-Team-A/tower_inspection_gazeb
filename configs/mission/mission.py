#!/usr/bin/env python3

import mission_execution_control as mxc
import rospy
from aerostack_msgs.msg import ListOfBeliefs
import math
import time


points = [[1, 0, 1.6], [7.5, 0, 1.6], [2, 0, 1.6],[3, 0, 6], [7, 0, 6], [3, 0, 6], [3, 0, 10.6], [7, 0, 10.6], [3, 0, 10.6], [3, 0, 15], [7, 0, 15], [0, 0, 15]]
  


def mission():
	global qr_codes
	print("Starting mission...")
 # api.executeBehavior('CLEAR_OCCUPANCY_GRID')
	print("Taking off...")
	mxc.executeTask('TAKE_OFF')
	mxc.startTask('HOVER')
  	mxc.startTask('PID_MOTION_CONTROL')
	mxc.startTask('CLEAR_OCCUPANCY_GRID')
  	print("Take off completed...")
  	floor = 0
  	for j, point in enumerate (points, 0):
      		retry = 0
		exit_code = 3
      		print("Generating path")
      		print (str(point))
      		while (retry == 0 or exit_code == 3):	   		
	   		if (j == 0 or j ==3 or j ==6 or j == 9):
				
				if (j != 0):
	   				exit_code = mxc.executeTask('FOLLOW_PATH', path=[points[j-1], points[j]])[1]
				else:
					exit_code = mxc.executeTask('FOLLOW_PATH', path=[points[j]])[1]
	   			mxc.startTask('CLEAR_OCCUPANCY_GRID')
	   			retry = 1
			else:
				if (j == 4):
					time.sleep(2)
				traject = mxc.executeTask('GENERATE_PATH', destination=point)
        			query = "path(?x,?y)"	  
      				success , unification = mxc.queryBelief(query)
      				if success:
					x = str(unification['x'])
           				y = str(unification['y'])
					predicate_path = "path(" + x + "," + y + ")"
					mxc.removeBelief(predicate_path)
					predicate_object = "object(" + x + ", path)"
					mxc.removeBelief(predicate_object)
					traject = eval(unification['y'])
           				traject = [[b for b in a ]for a in traject]
	   				print ("Moving to"+str(traject[len(traject)-1]))
           				print len(traject)
           				print ("Following path")
           				print ("---------------------------------")
	   				print (j)
	   
           				exit_code = mxc.executeTask('FOLLOW_PATH', path=traject)[1]
					if (j == 1 or j == 4 or j == 7 or j == 10):
						if (exit_code != 3):
							print (j)
             						mxc.startTask('SAVE_OCCUPANCY_GRID', map_name="$AEROSTACK_PROJECT/maps/planta" + str(floor))
							floor = floor +1
							if (j == 1):
								mxc.startTask('CLEAR_OCCUPANCY_GRID')
					retry = 1
					if (exit_code == 3):
						mxc.startTask('CLEAR_OCCUPANCY_GRID')
						retry = 0	
				else:
           				print("next iteration")
	   				mxc.startTask('CLEAR_OCCUPANCY_GRID')
  
  	result = mxc.executeTask('LAND')
  	mxc.executeTask('CLEAR_OCCUPANCY_GRID')
  	print('Finish mission...')
