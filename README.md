# Tidlor AI Agent Blueprint Workshop

เว็บ Workshop หน้าเดียว (single page, สลับ Tab ไม่ reload) deploy ได้บน Vercel หรือ Netlify และเก็บข้อมูลใน Supabase

- `index.html` + `app.js` — รวม 3 มุมมองไว้ในหน้าเดียว สลับด้วยแท็บบน header:
  - **Agent Spark** — สำหรับ AI Gangs Talk ใช้ 7–10 นาที
  - **Blueprint Lab** — แบบละเอียดสำหรับ Workshop ครั้งถัดไป (เปิด/ปิดได้จากหน้า Admin ดูหัวข้อ "เปิด/ปิด Blueprint Lab" ด้านล่าง)
  - **Admin Dashboard** — สำหรับทีม Admin ดูรายการ, กรอง/ค้นหา, รีเฟรชข้อมูล, ดูรายละเอียดแต่ละงาน, ดาวน์โหลดเป็น JSON ทีละอันหรือเลือกหลายอันพร้อมกัน

## ทดลองในเครื่อง

เปิดผ่าน local web server (อย่า double-click เพราะ ES modules ต้องใช้ HTTP):

```bash
npx serve .
```

หากยังไม่ตั้ง Supabase ระบบจะบันทึกแบบทดลองใน browser localStorage

## เชื่อม Supabase

1. สร้าง Supabase project
2. เปิด SQL Editor และรัน `supabase.sql`
3. คัดลอก Project URL และ anon public key ไปใส่ `config.js`
4. สร้างผู้ใช้ Admin ที่ Authentication > Users
5. นำ UUID ของผู้ใช้ไปเพิ่มใน `workshop_admins` ตามคำสั่งท้ายไฟล์ SQL — **ขั้นตอนนี้จำเป็น** ถ้าข้ามไป จะ login เข้า Admin ได้แต่ Dashboard จะว่างเปล่า และปุ่มบันทึกต่าง ๆ จะ error

อย่าใส่ `service_role` key ในเว็บเด็ดขาด ใช้เฉพาะ anon public key; RLS จะเปิดให้ผู้เข้าร่วม insert แต่ไม่สามารถอ่านข้อมูลคนอื่นได้

`SUPABASE_URL` ใน `config.js` ต้องเป็น **Project URL** จาก Settings > API (รูปแบบ `https://xxxx.supabase.co`) อย่าเผลอใส่ Database host จากหน้า Connection String (`db.xxxx.supabase.co`) เพราะจะทำให้ทั้งเว็บพังตั้งแต่โหลดหน้าแรก

## เปิด/ปิด Blueprint Lab

สถานะเปิด/ปิดเก็บอยู่ในตาราง `app_settings` (คีย์ `lab_enabled`) ไม่ใช่ค่าที่ฝังในโค้ด จึงเปลี่ยนได้ทันทีโดยไม่ต้อง deploy ใหม่:

1. Login เข้าหน้า Admin (ต้องเป็นผู้ใช้ใน `workshop_admins`)
2. กดสวิตช์ "เปิดใช้งาน Blueprint Lab" ที่ด้านบนของ Dashboard
3. ผู้เข้าร่วมที่โหลดหน้าเว็บใหม่จะเห็นแท็บ Blueprint Lab ทันที (ค่าเริ่มต้นหลังรัน `supabase.sql` คือปิดไว้ก่อน)

ถ้ายังไม่ได้ตั้งค่า Supabase (โหมดทดลองในเครื่อง) ระบบจะเปิด Blueprint Lab ให้เสมอ เพื่อให้ทดสอบฟีเจอร์ได้ครบ

## Deploy Vercel

Import โฟลเดอร์นี้เป็น Project, Framework Preset = Other, Build Command เว้นว่าง, Output Directory = `.`

## Deploy Netlify

ลากโฟลเดอร์ขึ้น Netlify Drop หรือเชื่อม Git repository โดย Publish Directory = `.`

## การคัดเลือก AI Agent Hero

Agent Spark ไม่แสดงคะแนนแก่พนักงาน Dashboard ใช้สัญญาณความชัดของไอเดียควบคู่กับความสมัครใจ ส่วน Blueprint Lab มีคะแนนความครบ 4 ด้านสำหรับจัดลำดับการอ่านเท่านั้น ไม่ใช่การประเมินผลงาน แล้วสัมภาษณ์เจ้าของงานโดยดูเพิ่มว่า:

- งานมีคุณค่าชัดและวัดผลได้
- เจ้าของงานอธิบายขั้นตอนได้ดีและพร้อมทดลอง
- ข้อมูลพร้อมหรือเริ่มจากไฟล์ได้
- เข้าใจข้อจำกัดและ Human Gate
- พร้อมแบ่งปันสิ่งที่เรียนรู้ให้ทีมอื่น

## Privacy

ควรแจ้งวัตถุประสงค์ ระยะเวลาเก็บ ผู้เข้าถึง และช่องทางขอลบข้อมูลตามนโยบายบริษัทก่อนใช้งานจริง รหัสพนักงานถือเป็นข้อมูลส่วนบุคคลในบริบทองค์กร
