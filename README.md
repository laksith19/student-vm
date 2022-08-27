## What? Why? How?

Just a way to automate the build process of the 162 student VMs but a  different implementation to the one in use currently by the course.
It follows the same structure as upstream but swaps out debootstrap + chroot for cloud init. The primary advantage for this method would be not having to 
deal with the creation of disk image, and is distro agnostic for the most part. The disadantage at this point is that if we need the build process to be contained within docker, it'll take a painfully
long time. The current builds took ~1hr to complete which is not ideal (but for what it's worth it works fine). It would be viable if we choose to run the config
process directly on the host (~4 mins) or decide to configure at first boot on the students machines - but this could potentially cause more setup issues.  
