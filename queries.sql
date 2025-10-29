--1.A.

SELECT v.name, p.productid
FROM vendor v
JOIN productvendor p ON v.businessentityid = p.businessentityid
WHERE v.creditrating = 5 AND p.productid > 500;

-- Create an index on vendor.creditrating
CREATE INDEX idx_creditrating ON vendor(creditrating);

-- Create an index on productvendor.productid
CREATE INDEX idx_productid ON productvendor(productid);


--1.B.

SELECT pod.purchaseorderid, poh.orderdate, pod.purchaseorderdetailid, pod.orderqty, pod.productid
FROM purchaseorderheader poh
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
WHERE pod.orderqty > 500;

-- Create an index on purchaseorderdetail.orderqty
CREATE INDEX idx_orderqty ON purchaseorderdetail(orderqty);

-- Optimized Query
SELECT pod.purchaseorderid, poh.orderdate, pod.purchaseorderdetailid, pod.orderqty, pod.productid
FROM purchaseorderheader poh
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
WHERE pod.orderqty > 500;

--1.C.

SELECT poh.purchaseorderid, v.businessentityid AS vendornumber, pod.purchaseorderdetailid, pod.productid, pod.unitprice
FROM purchaseorderheader poh
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
JOIN vendor v ON poh.vendorid = v.businessentityid
WHERE poh.purchaseorderid BETWEEN 1400 AND 1600;

-- Create an index on purchaseorderheader.purchaseorderid
CREATE INDEX idx_purchaseorderid ON purchaseorderheader(purchaseorderid);

-- Optimized Query
SELECT poh.purchaseorderid, v.businessentityid AS vendornumber, pod.purchaseorderdetailid, pod.productid, pod.unitprice
FROM purchaseorderheader poh
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
JOIN vendor v ON poh.vendorid = v.businessentityid
WHERE poh.purchaseorderid BETWEEN 1400 AND 1600;


--1.D.

SELECT v.businessentityid, COUNT(poh.purchaseorderid) AS ordercount, SUM(pod.unitprice * pod.orderqty) AS totalcost
FROM vendor v
LEFT JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
LEFT JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
GROUP BY v.businessentityid
ORDER BY totalcost DESC;

-- Create an index on purchaseorderheader.vendorid
CREATE INDEX idx_vendorid ON purchaseorderheader(vendorid);

-- Optimized Query
SELECT v.businessentityid, COUNT(poh.purchaseorderid) AS ordercount, SUM(pod.unitprice * pod.orderqty) AS totalcost
FROM vendor v
LEFT JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
LEFT JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
GROUP BY v.businessentityid
ORDER BY totalcost DESC;

--1.E.

SELECT AVG(ordercount) AS avgorders, AVG(totalcost) AS avgcost
FROM (
    SELECT v.businessentityid, COUNT(poh.purchaseorderid) AS ordercount, SUM(pod.unitprice * pod.orderqty) AS totalcost
    FROM vendor v
    LEFT JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
    LEFT JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
    GROUP BY v.businessentityid
);

--1.F.

SELECT v.businessentityid, v.name, SUM(pod.rejectedqty)/SUM(pod.receivedqty) * 100 AS rejection_percentage
FROM vendor v
LEFT JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
LEFT JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
GROUP BY v.businessentityid, v.name
ORDER BY rejection_percentage DESC
FETCH FIRST 50 ROWS ONLY;

--1.G.

SELECT v.businessentityid, v.name, SUM(pod.orderqty) AS total_quantity_purchased
FROM vendor v
JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
GROUP BY v.businessentityid, v.name
ORDER BY total_quantity_purchased DESC
FETCH FIRST 10 ROWS ONLY;

--1.H.

SELECT pod.productid, SUM(pod.orderqty) AS total_quantity_purchased
FROM purchaseorderdetail pod
JOIN productvendor p ON pod.productid = p.productid
GROUP BY pod.productid
ORDER BY total_quantity_purchased DESC
FETCH FIRST 10 ROWS ONLY;

--1.I.

SELECT v.businessentityid, pod.productid, SUM(pod.orderqty) AS total_quantity_purchased, RANK() OVER (PARTITION BY v.businessentityid ORDER BY SUM(pod.orderqty) DESC) AS ranking
FROM vendor v
JOIN purchaseorderheader poh ON v.businessentityid = poh.vendorid
JOIN purchaseorderdetail pod ON poh.purchaseorderid = pod.purchaseorderid
JOIN productvendor p ON pod.productid = p.productid
GROUP BY v.businessentityid, pod.productid
ORDER BY v.businessentityid, ranking;

--2.J.

CREATE OR REPLACE TRIGGER trg_before_update_purchaseorderdetail
BEFORE UPDATE ON purchaseorderdetail
FOR EACH ROW
DECLARE
    v_purchaseorderid NUMBER;
BEGIN
    -- Insert a row into Transaction_History table
    INSERT INTO transaction_history
    VALUES (:OLD.purchaseorderid, :OLD.purchaseorderdetailid, :OLD.duedate,
            :OLD.orderqty, :OLD.productid, :OLD.unitprice, :OLD.receivedqty, :OLD.rejectedqty, :OLD.modifieddate);
    
    -- Update ModifiedDate in PurchaseOrderDetail
    :NEW.modifieddate := SYSTIMESTAMP;
    
    -- Update SubTotal in PurchaseOrderHeader
    SELECT purchaseorderid INTO v_purchaseorderid FROM purchaseorderdetail WHERE purchaseorderdetailid = :NEW.purchaseorderdetailid;
    UPDATE purchaseorderheader
    SET subtotal = (SELECT SUM(unitprice * orderqty) FROM purchaseorderdetail WHERE purchaseorderid = v_purchaseorderid)
    WHERE purchaseorderid = v_purchaseorderid;
END;
/

--2.K.

CREATE OR REPLACE TRIGGER trg_before_update_purchaseorderheader
BEFORE UPDATE ON purchaseorderheader
FOR EACH ROW
DECLARE
    v_new_subtotal NUMBER;
    v_detail_subtotal NUMBER;
BEGIN
    -- Check if the new SubTotal is consistent with data in PurchaseOrderDetail
    SELECT SUM(unitprice * orderqty) INTO v_new_subtotal FROM purchaseorderdetail WHERE purchaseorderid = :NEW.purchaseorderid;
    
    SELECT subtotal INTO v_detail_subtotal FROM purchaseorderheader WHERE purchaseorderid = :NEW.purchaseorderid;
    
    IF v_new_subtotal != v_detail_subtotal THEN
        RAISE_APPLICATION_ERROR(-20001, 'Inconsistent data in PurchaseOrderDetail. SubTotal cannot be updated.');
    END IF;
END;
/

-- PowerBI

SELECT
    pd.productid,
    SUM(pd.orderqty) AS total_quantity_sold
FROM
    purchaseorderdetail pd
GROUP BY
    pd.productid
ORDER BY
    total_quantity_sold DESC
FETCH FIRST 5 ROWS ONLY;









    