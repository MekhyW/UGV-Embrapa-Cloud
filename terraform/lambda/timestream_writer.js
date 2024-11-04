const { TimestreamWriteClient, WriteRecordsCommand } = require('@aws-sdk/client-timestream-write');
const client = new TimestreamWriteClient();

exports.handler = async (event) => {
    const records = event.Records.map(record => {
        const data = JSON.parse(Buffer.from(record.kinesis.data, 'base64').toString());
        const currentTime = Date.now().toString();

        const topic = data.topic || 'unknown';
        
        return {
            Dimensions: [
                { Name: 'device_id', Value: data.thing_name || 'unknown' },
                { Name: 'topic', Value: topic }
            ],
            MeasureName: 'telemetry',
            MeasureValue: JSON.stringify(data.payload || data),
            MeasureValueType: 'VARCHAR',
            Time: currentTime,
            TimeUnit: 'MILLISECONDS'
        };
    });

    const params = {
        DatabaseName: process.env.TIMESTREAM_DATABASE,
        TableName: process.env.TIMESTREAM_TABLE,
        Records: records
    };

    try {
        await client.send(new WriteRecordsCommand(params));
        return { statusCode: 200, body: `Successfully processed ${records.length} records` };
    } catch (error) {
        console.error('Error writing to Timestream:', error);
        throw error;
    }
};
