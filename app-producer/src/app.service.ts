import { Injectable } from '@nestjs/common';
import { Client, ClientKafka, Transport } from '@nestjs/microservices';

@Injectable()
export class AppService {
  @Client({
    transport: Transport.KAFKA,
    options: {
      client: {
        clientId: 'kafka',
        brokers: ['kafka-1:9092', 'kafka-2:9092', 'kafka-3:9092'],
      },
      send: {
        acks: -1,
      },
      producer: {
        maxInFlightRequests: 1,
        transactionTimeout: 3000,
      },
    },
  })
  client: ClientKafka;

  async onModuleInit() {
    await this.client.connect();
  }

  sendToConsumer(message: string) {
    console.log('Message sending to consumer:', message);
    return this.client.emit('test', message);
  }

}
