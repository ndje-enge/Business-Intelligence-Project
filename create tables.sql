drop table purchaseorderdetail;
drop table purchaseorderheader;
drop table vendor;
drop table productvendor;

create table purchaseorderdetail (purchaseorderid integer, purchaseorderdetailid integer, duedate timestamp, orderqty integer, productid integer, unitprice numeric not null, receivedqty decimal(8, 2) not null, rejectedqty decimal(8, 2) not null, modifieddate timestamp);
create table purchaseorderheader (purchaseorderid integer, revisionnumber integer, status integer, employeeid integer, vendorid integer, shipmethodid integer, orderdate timestamp, shipdate timestamp, subtotal numeric, taxamt numeric, freight numeric, modifieddate timestamp);
create table vendor (businessentityid integer, accountnumber varchar2(50), name varchar2(50), creditrating integer, preferredvendorstatus VARCHAR2(50), activeflag VARCHAR2(50), purchasingwebserviceurl varchar2(60), modifieddate timestamp);
create table productvendor (productid integer, businessentityid integer, averageleadtime integer, standardprice numeric not null, lastreceiptcost numeric not null, lastreceiptdate timestamp not null, minorderqty integer, maxorderqty integer, onorderqty integer, unitmeasurecode varchar2(30), modifieddate timestamp);
ALTER TABLE purchaseorderdetail ADD CONSTRAINT pk_purchaseorderdetail PRIMARY KEY (purchaseorderid, purchaseorderdetailid);
ALTER TABLE purchaseorderheader ADD CONSTRAINT pk_purchaseorderheader PRIMARY KEY (purchaseorderid);
ALTER TABLE vendor ADD CONSTRAINT pk_vendor PRIMARY KEY (businessentityid);
ALTER TABLE productvendor ADD CONSTRAINT pk_productvendor PRIMARY KEY (productid,businessentityid);
ALTER TABLE purchaseorderdetail ADD CONSTRAINT fk_purchaseorderdetailid FOREIGN KEY (purchaseorderid) REFERENCES purchaseorderheader(purchaseorderid);
ALTER TABLE productvendor ADD CONSTRAINT fk_businessentityid FOREIGN KEY (businessentityid) REFERENCES vendor(businessentityid);

select * from vendor;