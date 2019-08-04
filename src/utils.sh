#!/bin/bash
function BOOT ()
{
  A=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
  while [[ $A != "1" ]]; do
          sleep 1;
          A=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
  done;
}

function wait_emulator_to_be_ready () {
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi
  done
}

function change_language_if_needed() {
  if [ ! -z "${LANGUAGE// }" ] && [ ! -z "${COUNTRY// }" ]; then
    wait_emulator_to_be_ready
    echo "Languge will be changed to ${LANGUAGE}-${COUNTRY}"
    adb root && adb shell "setprop persist.sys.language $LANGUAGE; setprop persist.sys.country $COUNTRY; stop; start" && adb unroot
    echo "Language is changed!"
  fi
}

function install_google_play () {
  wait_emulator_to_be_ready
  echo "Google Play Store will be installed"
  adb install -r  "/root/google_play_store.apk"
  echo "Google Play Service will be installed"
  adb install -r  "/root/google_play_services.apk"
  adb shell pm clear  com.google.android.gms
  echo "Google chrome will be installed"
  adb install -r "/root/google_chrome.apk"
}

function disable_animation () {
  # To improve performance
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}

function QA () {
  # checker="$(adb shell 'su 0 ls /mnt/sdcard/Download/qa101.jpg > /dev/null 2>&1 && echo "yes" || echo "no"')"
  resp=$(adb shell "ls -1 /mnt/sdcard/Download/ | wc -l")
  echo $resp
}

function Push () {
  echo "Pushing Images :"
  counter=$(QA)
  if [[ $counter -ne "8" ]]; then
    while [[ $counter -ne "8" ]];
    do
      touch -a -m /media/*.jpg
      adb push -p /media/* /mnt/sdcard/Download
      sleep 1;
      counter=$(QA)
      echo "Pushed images : ${counter}"

    done;
    #adb shell  'su 0 am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///mnt/sdcard/Download'
    adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///mnt/sdcard/Download
    adb shell  "ls /mnt/sdcard/Download"
  else
      echo "Available images : ${counter}"
  fi
}

function Fake_Geo () {
  wait_emulator_to_be_ready
  # adb shell "su root pm disable com.google.android.googlequicksearchbox"
  # adb shell "su root settings put secure location_providers_allowed +network"
  adb -s emulator-5554 emu geo fix 51.4 35.7 1400
}

change_language_if_needed
sleep 1
install_google_play
Push
Fake_Geo
disable_animation


# adb shell 'su 0 settings put secure location_providers_allowed +gps'
# adb root
# adb shell "setprop persist.sys.language fa; setprop persist.sys.country IR; setprop ctl.restart zygote"
# adb shell 'su 0 settings put global window_animation_scale 0.0'
# adb shell 'su 0 settings put global transition_animation_scale 0.0'
# adb shell 'su 0 settings put global animator_duration_scale 0.0'
# adb shell 'su 0 settings put secure show_ime_with_hard_keyboard 0'
 # adb shell 'su 0 settings put secure location_providers_allowed +gps'
 # adb shell settings put secure location_providers_allowed gps,network
# adb shell 'su 0 am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE fa_IR'
# adb shell 'su 0 settings put secure location_providers_allowed +network'
# adb shell 'su 0 pm grant com.sheypoor.mobile.debug android.permission.ACCESS_FINE_LOCATION'
