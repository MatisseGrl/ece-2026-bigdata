import argparse
import os
import duckdb


def orders_report(product=None):
    con = duckdb.connect()
    con.execute("SET TimeZone = 'UTC'")

    bronze = f"s3://{os.environ['KUBERNETES_NAMESPACE']}/bronze"

    return con.execute(
        f"""
        SELECT
            strftime(date, '%Y-%m') AS month,
            count(*) AS orders,
            sum(quantity) AS quantity
        FROM read_csv('{bronze}/orders.csv', strict_mode=false)
        WHERE $product IS NULL OR product = $product
        GROUP BY month
        ORDER BY month
        """,
        {"product": product},
    ).fetchall()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--product")
    args = parser.parse_args()

    for month, orders, quantity in orders_report(args.product):
        print(f"{month}\t{orders}\t{quantity}")


if __name__ == "__main__":
    main()
