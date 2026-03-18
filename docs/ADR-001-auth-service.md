# ADR-001: เพิ่ม Auth Service แยกจาก Task Service

## Status
Accepted

## Context
ระบบเดิมใน Week 6 มีเพียง Task Service และ Frontend ซึ่ง Task Service ต้องรับหน้าที่จัดการทั้งทางฝั่ง Bussiness Logic และดูแลเรื่องความปลอดภัย (ไม่มี Authentication/Authorization ที่แท้จริง ทำให้ใครก็สามารถเข้าถึงและแก้ไขข้อมูลของผู้อื่นได้) เมื่อระบบขยายตัวหรือมี Service อื่นๆ เพิ่มขึ้น การให้แต่ละ Service จัดการเรื่อง Authentication ด้วยตัวเองจะนำไปสู่ Code Duplication, จัดการยาก, และมีความเสี่ยงต่อช่องโหว่ทางความปลอดภัยสูงขึ้น

## Decision
ตัดสินใจแยกกระบวนการ Authentication และการจัดการผู้ใช้ออกมาเป็น Microservice ใหม่ตัวหนึ่งชื่อว่า **Auth Service** โดยทำงานร่วมกับ **User Service** และ **API Gateway (Nginx)**:
1. **Auth Service**: รับหน้าที่เดียวคือพิสูจน์ตัวตน (Login/Register) แฮชรหัสผ่าน และออก JWT Token 
2. **Nginx API Gateway**: ทำหน้าที่เป็นด่านหน้าคอย Route traffic และแนบ Token ไปให้ Service หลังบ้าน 
3. **Task Service / User Service**: เปลี่ยนมาใช้ JWT Middleware เพื่อทำหน้าที่เช็คความถูกต้องของ Token ก่อนอนุญาตให้ใช้งาน API ข้อมูล (Authorization) แทนที่จะต้องตรวจสอบรหัสผ่านด้วยตัวเอง

## Consequences
**Positive:**
- **Single Responsibility Principle (SRP)**: แต่ละ Service ทำหน้าที่ชัดเจน Auth Service ดูแลแค่การยืนยันตัวตน Task Service ดูแลเรื่องงาน
- **Security & Authorization**: ระบบมีความปลอดภัยสูงขึ้น ข้อมูลถูกป้องกันด้วย JWT และสามารถระบุ Role (เช่น Admin, Member) เพื่อจำกัดสิทธิการเข้าถึงข้อมูลของกันและกันได้
- **Scalability**: สามารถ Scale ตัว Auth Service แยกต่างหากได้หากมีการ Login จำนวนมากโดยไม่กระทบกับ Task Service
- **Defense in Depth**: การเพิ่ม Nginx ที่ตั้ง Rate Limiting ควบคู่ช่วยป้องกันการ Brute-force โจมตี Auth Service ได้

**Negative:**
- **Complexity**: ระบบโดยรวมมีความซับซ้อนเพิ่มขึ้นอย่างมาก ต้องจัดการ Container เพิ่มเติม (จาก 3 เป็น 9 ตัวรวม DB/Logging)
- **Latency**: การมี API Gateway และการตรวจสอบ JWT ในแต่ละ Service เพิ่มโหลดให้กับการตอบสนองของ API เล็กน้อย (~5ms)
- **Operational Overhead**: ต้องจัดการโครงข่ายรหัสลับ (JWT_SECRET) ระหว่าง Service ให้ตรงกันเสมอ

**Trade-offs:**
- ยอมรับความซับซ้อนและ Latency เล็กน้อยที่เพิ่มขึ้นในระดับ Infrastructure เพื่อแลกกับความปลอดภัย (Security), การจัดระเบียบโค้ด (Maintainability), และความสามารถในการขยายระบบในระยะยาว (Scalability) ตามหลักการของ Microservices
