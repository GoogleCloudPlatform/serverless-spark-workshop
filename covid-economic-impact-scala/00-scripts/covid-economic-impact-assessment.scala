package org.teksystems

import org.apache.spark.sql.SparkSession
import org.apache.spark.SparkConf
import org.apache.spark.sql.functions._

object covideconomicimpact {
    def main(args: Array[String]) {

// Ensuring the expected number of input parameters is supplied

    if (args.length != 4) {
            throw new IllegalArgumentException(
                        "Exactly 4 arguments are required: <Project ID> <Dataset Name> <Bucket Name> <User Name>")
                }

// Reading the arguments and storing them in variables

    val project_id=args(0)
    val dataset_name=args(1)
    val bucket_name=args(2)
    val user_name=args(3)

// Creating a Spark Session

    val spark = SparkSession.builder().appName("Covid-Economic-Impact-Assessment").master("local").getOrCreate()

// Assigning temporary bucket for BQ write

    spark.conf.set("temporaryGcsBucket",bucket_name)

// Reading Input Data Files

    val stock_df = spark.read.option("delimiter", ";").option("header", "true").csv("gs://"+bucket_name+"/covid-economic-impact-scala/01-datasets/stock.csv")
    val stringency_df = spark.read.option("delimiter", ";").option("header", "true").csv("gs://"+bucket_name+"/covid-economic-impact-scala/01-datasets/stringency.csv")

// Extract columns to create Country, Stock and Time tables

    val country_table = stringency_df.selectExpr("Code as country_code","Country as country").dropDuplicates()
    val stock_table = stock_df.selectExpr("Ticker as stock_id","names as company_name","Sector as sector").dropDuplicates()
    val time_table = stringency_df.select(col("Date"),dayofmonth(col("Date")).as("day"),month(col("Date")).as("month"),year(col("Date")).as("year"),dayofweek(col("Date")).as("weekday")).dropDuplicates()

// Creating temporary views for stock and stringency data to analyze and identify high strigency stocks

    stock_df.createOrReplaceTempView("stocks")
    stringency_df.createOrReplaceTempView("stringency")

// Identifying high stringency stocks using Spark SQL on temporary views

    val ec_status_table = spark.sql("SELECT DISTINCT monotonically_increasing_id() as ec_status_id, stringency.Date as date, stringency.Code as country_code, stringency.Stringency_Index as stringency_index, stocks.Ticker as stock_id, stocks.Value_Type as value_type, stocks.Value as value FROM stocks JOIN stringency ON stocks.Date = stringency.Date AND stocks.Country = stringency.Country")


// Writing Output Data into BigQuery

    (country_table.write.format("bigquery").option("table",dataset_name+"."+user_name+"_countries").save())
    (stock_table.write.format("bigquery").option("table",dataset_name+"."+user_name+"_stocks").save())
    (ec_status_table.write.format("bigquery").option("table",dataset_name+"."+user_name+"_ec_status").save())
    (time_table.write.format("bigquery").option("table",dataset_name+"."+user_name+"_times").save())

    }
}
