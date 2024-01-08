/*

Stored Procedure in Sql - Procedure without Parameters , Procedure with Parameters

*/

--Procedure without Parameters

Drop table if exists sales
Create Table sales
    (order_id int, order_date date, product_code varchar(20), quantity_ordered int, sale_price varchar(100));

Insert Into sales 
Values     (1, '2022-01-10', 'P1', 100, '120000'),
           (2, '2022-01-20', 'P1', 50, '60000'),
		   (3, '2022-02-05', 'P1', 45, '540000');

Select *
From sales

Drop table if exists product

Create Table product
       (product_code varchar(20), product_name varchar(100), price int, quantity_remaining int, quantity_sold int);

Insert Into product 
Values     ('P1', 'iphone 13 Pro Max', 1200, 5,  195);
       
Select * From product
Select * From sales

--For every iPhone 13 Pro Max sale, modify the database tables accordingly.

Create or alter procedure pr_buy_product
as
   declare @v_product_code  varchar(20),
           @v_price         float;
begin
   select @v_product_code = product_code, @v_price = price
   from product
   where product_name = 'iphone 13 Pro Max';

   insert into sales(order_date, product_code, quantity_ordered, sale_price)
   values (cast(getdate() as date), @v_product_code, 1, (@v_price * 1));

   update product
   set quantity_remaining = (quantity_remaining - 1)
   , quantity_sold = (quantity_sold + 1)
   where product_code = @v_product_code;

   print('Product Sold!');

end;

Select * From product
Select * From sales

exec pr_buy_product;

drop proc pr_buy_product

-----------------------------------------------------------------------------------------------
--Procedure with parameters

--Im inserting few more reords into the product table

Insert Into product 
Values     ('P1', 'iphone 13 Pro Max', 1200, 5,  195),
           ('P2', 'AirPods Pro' , 279, 10, 90),
		   ('P3', 'MacBook Pro', 5000, 2, 48),
		   ('P4', 'iPad Air', 650, 1, 9);

Select * From product

Insert Into sales 
Values     (4, '2022-01-15', 'P2', 50, '13950'),
           (5, '2022-03-25', 'P2', 40, '11160'),
		   (6, '2022-02-25', 'P3', 10, '50000'),
		   (7, '2022-03-15', 'P3', 10 , '50000'),
		   (8, '2022-03-25', 'P3', 20, '100000'),
		   (9, '2022-04-21', 'P3', 8, '40000'),
		   (10, '2022-04-27', 'P4', 9, '5850');


--For every given product and the quantity:
--1) check if product is available based on the required quantity
--2) if available then modify the database tables accordingly.

--For every given product and the given quantity check if the product is available based on the required quantity
--and if it is available then modify the database tables accordingly means you'll be given the product also you'll be given 
--how much quantity of that product is required to be sold as per that particular sales order and you need to first check
--in the database if so many products are actually available if it is available only then do the modification if it is not 
--available then may be return a meaningful message 

Create or alter procedure pr_buy_product(@p_product_name varchar, @p_quantity int)
as
   declare @v_product_code  varchar(20),
           @v_price         float;
		   @v_cnt           int;
begin
   select @v_cnt = count(1)
   from product 
   where product_name = @p_product_name
   and quantity_remaining >= @p_quantity;

   if @v_cnt > 0
   begin
       select @v_product_code = product_code, @v_price = price
	   from product
	   where product_name = @p_product_name;

       insert into sales(order_date, product_code, quantity_ordered, sale_price)
       values (cast(getdate() as date), @v_product_code, @p_quantity, (@v_price * @p_quantity));

       update product
       set quantity_remaining = (quantity_remaining - @p_quantity)
           ,quantity_sold = (quantity_sold + @p_quantity)
       where product_code = @v_product_code;

       print('Product Sold!');
   end
   else
       print('Insufficient Quantity!');
end;
--------------------------------------------------------------------------------------------