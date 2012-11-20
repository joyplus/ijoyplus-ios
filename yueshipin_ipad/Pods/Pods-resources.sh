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
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window@2x.png'
