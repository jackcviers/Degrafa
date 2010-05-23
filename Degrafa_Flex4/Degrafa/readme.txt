preliminary compatibility to compile for flex 4, based on trunk revision 636.

Library compiler settings:
namespace: 		http://www.degrafa.com/2007
manfest file: 	manifest.xml

to compile for flex 4, use compiler arguments: -locale en_US -define TARGET::FLEX4 true -define TARGET::FLEX3 false
to compile for flex 3, use compiler argumentsL -locale en_US -define TARGET::FLEX4 false -define TARGET::FLEX3 true