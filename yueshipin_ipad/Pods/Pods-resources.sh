#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/blackArrow.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/blackArrow@2x.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/blueArrow.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/blueArrow@2x.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/grayArrow.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/grayArrow@2x.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/whiteArrow.png'
install_resource 'EGOTableViewPullRefresh/EGOTableViewPullRefresh/Resources/whiteArrow@2x.png'
install_resource 'iRate/iRate/iRate.bundle'
