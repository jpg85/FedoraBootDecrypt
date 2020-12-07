# FedoraBootDecrypt
Dracut module to decrypt fedora on boot using file retreived by FTP

There isn't much here, but I decided to create the repository after having to try to set this up twice on different machines. Perhaps there is a better way, but this works reliably for me.

My setup is pretty straight forward: I have an essentially headless machine that has an encrypted root partition that needs to be decrypted on boot. The machine is local to me and I want it to decrypt without the need of a keyboard or any user input. While Fedora does offer some network boot capabilities, it is much more complex than necessary for a simple home setup. Instead, I've opted to plug a USB key into my router which contains the key to decrypt the device. Thus my goal is simple:
* Retreive the file from the USB key using FTP (I would use SCP, but router has stock firmware only supporting FTP or SMB)
* Decrypt root device using the resulting key
* Continue booting

While this seems straightforward, a few things become roadblocks. First, Fedora can't do the above with any pre-existing modules. Second, assuming you add a custom module, by default, Fedora will still ask for a password unless you decrypt the device before the crypt dracut module gets inserted. Finally, the network interface isn't normally brought up before the root file system.

All of these can be overcome, and it turns out, quite simply. You just need to add the right bit of magic code in the right spot and things will fall into place, all the while without preventing fallback to a password prompt in the emergency situation the network can't be reached.

While the provided scripts can be improved (very easily, I suspect), I didn't do much beyond the bare minimum to accomplish my goal. A few things that would be nice:
* Support for boot parameter parsing. This would allow specifying things like file to be downloaded, host to retreive it from, etc.. For me, since I only have one file and one host, it was just as easy to encode it in the decrypt script.
* Integration with crypt module such that it can automatically fall back to password prompt without changing kernel parameters. This might be as simple as creating a timeout for password prompt. Again, I did as little as possible and opted to add "rd.luks=0" instead, which can be removed easily if I ever need to boot the machine manually.
* Use something other than BusyBox binary to perform FTP. I opted for BusyBox due to no dependencies, but realize it is less flexible for different architectures and protocols.

Without further ado, here is the process to get it to work:
* Copy 41get-key to /usr/lib/dracut/modules.d directory
* Change scripts to meet your local needs
* Obtain busybox binary and rename bb_ftpget (or whatever your choice, just update scripts accordingly)
* Change grub boot parameters to add "rd.luks=0" and remove any LUKS references (/etc/default/grub)
* Change grub boot parameters to add "rd.neednet=1" and "ip=dhcp" (or whatever is appropriate)
* Copy unlock.conf to /etc/dracut.conf.d directory

A couple of notes on provided files:
## unlock.conf
This file simply tells dracut to include a few key items. While crypt seems contrary to what is desired, it is easy to use this to ensure the decryption capabilities are part of the initramfs. Since crypt contains everything necessary to unlock a device, get-key can simply rely on it to pull in the necessary dependencies.

## module-setup.sh
Nothing special here. Probably could follow best practices better, but again, I took path of least resistance. "install" adds the dependencies in the locations that I expect them, and additionally adds cryptsetup binary (which isn't always added, depending on crypt module configuration).

## get-key.sh
Again, pretty straightforward. If the desired key file doesn't exist, attempt to retrieve it from the host. If the file then exists, then unlock the desired devices using UUID (and mapping to the given luks-*UUID* default format).

## check-get-key.sh
Honestly, don't know if this is correct. But intention is to notify that initqueue isn't finished until the key file is found (and perhaps could check mapping exist, but...path of least resistance.)

And voila, run dracut and grub2-mkconfig and you're done.
