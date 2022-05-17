#!/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "FermiBottle Tag Bundle Management Script" >&2
   echo >&2
   echo "Syntax: bundle_tags [-s <tagname> [-s ...] -d <tagname> [-d ...] [l|u|p|h|v]]" >&2
   echo "options:" >&2
   echo "s     Source Tags to bundle [Multiple -s flags allowed]." >&2
   echo "d     Destination Tags to write bundle to [Multiple -d flags allowed]." >&2
   echo "l     Shortcut for '-d latest'" >&2
   echo "u     Upload tags to dockerhub" >&2
   echo "p     Prune tags after upload" >&2
   echo "h     Print this Help." >&2
   echo "v     Verbose mode." >&2
   echo >&2
}

############################################################
# Main program                                             #
############################################################

src_tags=()
dst_tags=()
verbose=false
prune=false
upload=false

while getopts 's:d:luphv' OPTION; do
  case "$OPTION" in
    s)
      src_tags+=( "$OPTARG" )
      ;;
    d)
      dst_tags+=( "$OPTARG" )
      ;;
    l)
      dst_tags+=( "latest" )
      ;;
    u)
      upload=true
      ;;
    p)
      prune=true
      ;;
    v)
      verbose=true
      ;;
    h)
      Help
      exit;;
    ?)
      Help
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

arg_flag_list=()
push_flag_list=()

if [ $prune = true ]; then
  push_flag_list+=( " -p " )
fi

amend_list=()
for tag in ${src_tags[@]}; do
  amend_list+=( " --amend fssc/fermibottle:${tag} ")
done

for dest in ${dst_tags[@]}; do

  create_cmd="docker manifest create fssc/fermibottle:${dest} ${arg_flag_list[@]} ${amend_list[@]}"

  if [ $verbose = true ]; then echo ${create_cmd}; fi

  eval $create_cmd

  if [ $upload = true ]; then

    push_cmd="docker manifest push ${arg_flag_list} fssc/fermibottle:${dest} ${push_flag_list[@]}"

    if [ $verbose = true ]; then echo ${push_cmd}; fi

    eval $push_cmd

  fi
done
