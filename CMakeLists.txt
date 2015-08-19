cmake_minimum_required(VERSION 2.8.12)
project(kimtoy)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(KDEInstallDirs)
include(KDECompilerSettings)
include(KDECMakeSettings)

set(REQUIRED_QT_VERSION 5.0.0)
find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED Core Gui X11Extras)
set(KF5_MIN_VERSION 5.0.0)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Archive Plasma KDELibs4Support NewStuff KIO Config)
find_package(X11)

add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(${QT_INCLUDES} ${KF5_INCLUDES} ${KDE4_INCLUDES})
include_directories(${X11_X11_INCLUDE_PATH})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_definitions(-Wall -Wextra)

set(SHARED_MIME_INFO_MINIMUM_VERSION "0.30")
find_package(SharedMimeInfo REQUIRED)

find_package(OpenSSL REQUIRED)
include_directories(${OPENSSL_INCLUDE_DIR})

find_package(GLIB2)
find_package(GIO)
find_package(GObject)
find_package(IBus)
find_package(Pthread)
find_package(DBusCXX)
find_package(SCIM)
find_package(Strigi)
find_package(PNG)

############# check if libpng has apng support #############

if(PNG_FOUND)
    include(CheckCSourceCompiles)
    set(CMAKE_REQUIRED_INCLUDES ${PNG_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${PNG_LIBRARY})
    check_c_source_compiles(
"
#include <png.h>
int main()
{
    (void)png_get_num_frames((png_structp)0, (png_infop)0);
    return 0;
}
"
        PNG_HAS_APNG_SUPPORT
    )
else(PNG_FOUND)
    set(PNG_HAS_APNG_SUPPORT 0)
endif(PNG_FOUND)

if(${PNG_HAS_APNG_SUPPORT})
    message("-- Using system PNG")
else(${PNG_HAS_APNG_SUPPORT})
    message("-- Using internal PNG")
endif(${PNG_HAS_APNG_SUPPORT})

###################### ibus arguments ######################
### NOTE TODO remove following definition when ibus is able to run registered component
if(IBUS_FOUND)
    add_definitions(-DIBUS_LIBEXEC_DIR="\\\"${IBUS_LIBEXEC_DIR}\\\"")
else(IBUS_FOUND)
    add_definitions(-DIBUS_LIBEXEC_DIR="\\\"${CMAKE_INSTALL_PREFIX}/libexec\\\"")
endif(IBUS_FOUND)

########################## kimtoy ##########################

set(kimtoy_SRCS
    animator.cpp
    envsettings.cpp
    filtermenu.cpp
    impanel.cpp
    impanelagent.cpp
    impanelagent_p.cpp
    inputmethods.cpp
    kimtoy.cpp
    kssf.cpp
    main.cpp
    preeditbar.cpp
    propertywidget.cpp
    skinpixmap.cpp
    statusbar.cpp
    statusbarlayout.cpp
    theme.cpp
    themelistview.cpp
    themelistmodel.cpp
    themer.cpp
    themer_fcitx.cpp
    themer_none.cpp
    themer_plasma.cpp
    themer_sogou.cpp
    themeragent.cpp
)

kde4_add_ui_files(kimtoy_SRCS
    appearance.ui
    inputmethod.ui
    theme.ui
    performance.ui
)

qt4_add_dbus_adaptor(kimtoy_SRCS
    org.kde.impanel.xml
    impanel.h
    IMPanel
    impaneladaptor
    IMPanelAdaptor
)

kde4_add_kcfg_files(kimtoy_SRCS kimtoysettings.kcfgc)

kde4_add_executable(kimtoy ${kimtoy_SRCS})

target_link_libraries(kimtoy
    Qt5::X11Extras
    KF5::Archive
    KF5::ConfigWidgets
    KF5::KDELibs4Support
    KF5::Plasma
    KF5::NewStuff
    ${OPENSSL_LIBRARIES}
    ${X11_X11_LIB}
)

install(TARGETS kimtoy ${INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS kimtoy.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(PROGRAMS kimtoy.desktop DESTINATION ${AUTOSTART_INSTALL_DIR})
install(FILES kimtoy.knsrc DESTINATION ${CONFIG_INSTALL_DIR})
# install(FILES org.kde.impanel.xml DESTINATION ${DBUS_INTERFACES_INSTALL_DIR})

add_subdirectory(thumbnailer)
add_subdirectory(strigi-analyzer)
# add_subdirectory(po)

######################### apng plugin #########################
add_subdirectory(kimgio-apng)
########################## ibus glue ##########################
add_subdirectory(ibus-kconfig)
add_subdirectory(ibus-panel)
########################## scim glue ##########################
add_subdirectory(scim-kconfig)
add_subdirectory(scim-panel)
