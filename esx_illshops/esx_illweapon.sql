USE `fivem`;

CREATE TABLE `illegal_shops` (
 
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `item` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `drug` varchar (255) NOT NULL,
  `drugqte` int(11) NOT NULL,
  
  PRIMARY KEY (`id`)
);


INSERT INTO `illegal_shops` (name, item, price, drug, drugqte) VALUES
	('illweapon_vendor1','AK74_1',20000,'coke_pooch',5),
	('illweapon_vendor2','AK74_2',20000,'coke_pooch',8),
	('illweapon_vendor3','AK74_3',20000,'coke_pooch',10)

;

INSERT INTO `items` (name, label) VALUES
	('AK74_1','Canon AK74'),
	('AK74_2','Corps AK74'),
	('AK74_3','Culasse AK74'),
	('AK74_full','AK74')

;