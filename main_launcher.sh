#!/bin/bash

NUMID_DRONE=111
DRONE_SWARM_ID=1
MAV_NAME=hummingbird_laser

export AEROSTACK_PROJECT=${AEROSTACK_STACK}/projects/tower_inspection_gazebo

. ${AEROSTACK_STACK}/config/setup.sh
 

#---------------------------------------------------------------------------------------------
# INTERNAL PROCESSES
#---------------------------------------------------------------------------------------------
gnome-terminal  \
`#---------------------------------------------------------------------------------------------` \
`# Basic Behaviors                                                                             ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Basic Behaviors" --command "bash -c \"
roslaunch basic_quadrotor_behaviors basic_quadrotor_behaviors.launch --wait \
    namespace:=drone$NUMID_DRONE;
exec bash\"" \
`#---------------------------------------------------------------------------------------------` \
`# Gazebo motor speed controller                                                               ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Gazebo motor speed controller"  --command "bash -c \"
roslaunch motor_speed_controller motor_speed_controller.launch --wait \
  namespace:=drone$NUMID_DRONE \
  mav_name:=hummingbird;
exec bash\"" \
`#---------------------------------------------------------------------------------------------` \
`# Quadrotor Motion With PID Control                                                           ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Quadrotor Motion With PID Control" --command "bash -c \"
roslaunch quadrotor_motion_with_pid_control quadrotor_motion_with_pid_control.launch --wait \
    namespace:=drone$NUMID_DRONE \
    robot_config_path:=${AEROSTACK_PROJECT}/configs/drone$NUMID_DRONE;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Gazebo Interface                                                                            ` \
`#---------------------------------------------------------------------------------------------` \
  --tab --title "Gazebo Interface" --command "bash -c \"
roslaunch gazebo_interface gazebo_interface.launch --wait \
    robot_namespace:=drone$NUMID_DRONE \
    drone_id:=$DRONE_SWARM_ID \
    mav_name:=$MAV_NAME;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Move Base                                                                                   ` \
`#---------------------------------------------------------------------------------------------` \
  --tab --title "Move Base" --command "bash -c \"
roslaunch ${AEROSTACK_STACK}/launchers/move_base_launcher/move_base.launch --wait \
  drone_id_namespace:=drone$NUMID_DRONE \
  drone_id_int:=$NUMID_DRONE \
  config_path:=${AEROSTACK_PROJECT}/configs/move_base_files;
            exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Hector Slam                                                                                 ` \
`#---------------------------------------------------------------------------------------------` \
    --tab --title "Hector Slam" --command "bash -c \"
roslaunch ${AEROSTACK_STACK}/launchers/hector_slam_launchers/hector_slam.launch --wait \
  drone_id_namespace:=drone$NUMID_DRONE \
  drone_id_int:=$NUMID_DRONE;
            exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Python Interpreter                                                                          ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Python Interpreter" --command "bash -c \"
roslaunch python_based_mission_interpreter_process python_based_mission_interpreter_process.launch --wait \
  drone_id_namespace:=drone$NUMID_DRONE \
  drone_id_int:=$NUMID_DRONE \
  mission_configuration_folder:=${AEROSTACK_PROJECT}/configs/mission;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Belief Manager                                                                              ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Belief Manager" --command "bash -c \"
roslaunch belief_manager_process belief_manager_process.launch --wait \
    drone_id_namespace:=drone$NUMID_DRONE \
    drone_id:=$NUMID_DRONE \
    config_path:=${AEROSTACK_PROJECT}/configs/mission;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Belief Updater                                                                              ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Belief Updater" --command "bash -c \"
roslaunch belief_updater_process belief_updater_process.launch --wait \
    drone_id_namespace:=drone$NUMID_DRONE \
    drone_id:=$NUMID_DRONE;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Behavior Manager                                                                       ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Behavior manager" --command "bash -c \" sleep 2;
roslaunch behavior_manager behavior_manager.launch --wait \
  robot_namespace:=drone$NUMID_DRONE \
  catalog_path:=${AEROSTACK_STACK}/config/mission/behavior_catalog.yaml;
exec bash\""  &

gnome-terminal \
`#---------------------------------------------------------------------------------------------` \
`# Belief Memory Viewer                                                                        ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Belief memory Viewer" --command "bash -c \"
roslaunch belief_memory_viewer belief_memory_viewer.launch --wait \
  robot_namespace:=drone$NUMID_DRONE \
  drone_id:=$NUMID_DRONE;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Behavior Execution Viewer                                                                   ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Behavior Execution Viewer" --command "bash -c \"
roslaunch behavior_execution_viewer behavior_execution_viewer.launch --wait \
  robot_namespace:=drone$NUMID_DRONE \
  drone_id:=$NUMID_DRONE \
  catalog_path:=${AEROSTACK_STACK}/config/mission/behavior_catalog.yaml;
exec bash\""  \
`#---------------------------------------------------------------------------------------------` \
`# Navigation With Lidar Behaviors                                                             ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "Navigation With Lidar" --command "bash -c \"
roslaunch navigation_with_lidar navigation_with_lidar.launch --wait \
  namespace:=drone$NUMID_DRONE \
  clearance:=0.30;
exec bash\"" &

gnome-terminal  \
`#---------------------------------------------------------------------------------------------` \
`# alphanumeric_viewer                                                                         ` \
`#---------------------------------------------------------------------------------------------` \
--tab --title "alphanumeric_viewer"  --command "bash -c \"
roslaunch alphanumeric_viewer alphanumeric_viewer.launch --wait \
    drone_id_namespace:=drone$NUMID_DRONE;
exec bash\""  &

`#---------------------------------------------------------------------------------------------` \
`# Rviz (To show the occupancy_grid)                                                           ` \
`#---------------------------------------------------------------------------------------------` \
rosrun rviz rviz -d ${AEROSTACK_PROJECT}/configs/drone$NUMID_DRONE/mapping.rviz

