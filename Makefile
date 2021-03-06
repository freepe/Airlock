# Dependancies
# ============
# genisoimage
# wine
# inno setup (iscc.exe)
# dmg (libdmg-hfsplus)
# wget, unzip

electron_version = v1.21.1
PROJECT = Airlock
VERSION = 0.6
ISCC = "../inno/ISCC.exe"

none:
	
#Download Electron for desired platforms
#=======================================
getelectron:
	rm ../electron -rf
	mkdir -p ../electron
	wget -P ../electron/ https://github.com/atom/electron/releases/download/$(electron_version)/electron-$(electron_version)-linux-x64.zip
	wget -P ../electron/ https://github.com/atom/electron/releases/download/$(electron_version)/electron-$(electron_version)-win32-ia32.zip
	wget -P ../electron/ https://github.com/atom/electron/releases/download/$(electron_version)/electron-$(electron_version)-win32-x64.zip
	wget -P ../electron/ https://github.com/atom/electron/releases/download/$(electron_version)/electron-$(electron_version)-darwin-x64.zip
	unzip -d ../electron/linux/ ../electron/electron-$(electron_version)-linux-x64.zip
	unzip -d ../electron/win32/ ../electron/electron-$(electron_version)-win32-ia32.zip
	unzip -d ../electron/win64/ ../electron/electron-$(electron_version)-win32-x64.zip
	unzip -d ../electron/darwin/ ../electron/electron-$(electron_version)-darwin-x64.zip

#Build libdmg-hfsplus
#====================
getdmg:
	git clone https://github.com/vasi/libdmg-hfsplus/
	cd libdmg-hfsplus && cmake . && make
	libdmg-hfsplus/dmg/dmg --help

#Create OSX dmg package
#======================
darwin:
	rm build/darwin -rf
	mkdir -p build/darwin/
	cp ../electron/darwin/* build/darwin -R
	rm build/darwin/LICENSE
	rm build/darwin/version
	cp platform/Info.plist build/darwin/Electron.app/Contents
	cp platform/airlock.icns build/darwin/Electron.app/Contents/Resources
	rm build/darwin/Electron.app/Contents/Resources/default_app -rf
	mkdir build/darwin/Electron.app/Contents/Resources/app
	cp gui/* build/darwin/Electron.app/Contents/Resources/app -R
	rm build/darwin/Electron.app/Contents/Resources/app/images/airlock_icon.ico
	mv build/darwin/Electron.app build/darwin/Airlock.app

	genisoimage -D -V "$(PROJECT) $(VERSION)" -no-pad -r -apple -o build/$(PROJECT)-$(VERSION)-uncompressed.dmg build/darwin/
	../libdmg-hfsplus/dmg/dmg dmg build/$(PROJECT)-$(VERSION)-uncompressed.dmg build/$(PROJECT)-$(VERSION).dmg
	rm build/$(PROJECT)-$(VERSION)-uncompressed.dmg

#Create Windows Inno Setup package
#=================================
win64:
	rm build/win64 -rf
	mkdir -p build/win64/
	cp ../electron/win64/* build/win64/ -R
	mv build/win64/electron.exe build/win64/airlock.exe
	rm build/win64/resources/default_app -rf
	mkdir build/win64/resources/app
	cp gui/* build/win64/resources/app -R
	wine $(ISCC) /Obuild /F$(PROJECT)-$(VERSION)_x64_setup platform/airlock64.iss

#Create Windows Inno Setup package
#=================================
win32:
	rm build/win32/ -rf
	mkdir -p build/win32/
	cp ../electron/win32/* build/win32/ -R
	mv build/win32/electron.exe build/win32/airlock.exe
	rm build/win32/resources/default_app -rf
	mkdir build/win32/resources/app
	cp gui/* build/win32/resources/app -R
	wine $(ISCC) /Obuild /F$(PROJECT)-$(VERSION)_ia32_setup platform/airlock32.iss

#Create Linux tar.gz
#===================
linux:
	rm build/linux -rf
	mkdir -p build/linux/
	cp ../electron/linux/* build/linux/ -R
	mv build/linux/electron build/linux/airlock
	rm build/linux/resources/default_app -rf
	mkdir build/linux/resources/app
	cp gui/* build/linux/resources/app -R
	rm build/linux/resources/app/images/airlock_icon.ico
	tar -cvjf build/$(PROJECT)-$(VERSION).tar.bz2 --transform s/linux/$(PROJECT)-$(VERSION)/ -C build linux/ 

all: darwin win32 win64 linux

clean:
	rm build/ -rf

cleanelectron:
	rm electron/ -rf
