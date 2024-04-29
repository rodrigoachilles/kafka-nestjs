import { Controller, Get } from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';

@Controller()
export class AppController {

  @MessagePattern('test')
  getHello(@Payload() msg: any) {
    console.log('Message received from producer:', msg);
    return `Consuming the message: ${msg}`;
  }

}
