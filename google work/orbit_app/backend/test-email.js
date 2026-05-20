const nodemailer = require('nodemailer');

async function testSMTP() {
  const smtpUser = '981c2e001@smtp-brevo.com';
  const smtpPass = 'xsmtpsib-1134de3da0153c261d21cd25930454716a9ab51af0dc56ca1e7fc40e683823ca-scfmkqf4HyabRaFH';
  const senderEmail = 'moin69603@gmail.com';

  console.log(`Testing SMTP authentication with login: ${smtpUser}...`);
  const transporter = nodemailer.createTransport({
    host: 'smtp-relay.brevo.com',
    port: 587,
    secure: false,
    auth: {
      user: smtpUser,
      pass: smtpPass
    }
  });

  try {
    await transporter.verify();
    console.log(`✅ SMTP authentication verified successfully!`);

    const mailOptions = {
      from: `"Orbit Test" <${senderEmail}>`,
      to: 'moin69603@gmail.com',
      subject: 'Orbit SMTP Test',
      text: 'If you receive this, the Brevo SMTP configuration is working perfectly!'
    };

    console.log('Sending test email...');
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Test email sent successfully! Response:', info.response);
  } catch (error) {
    console.log('❌ Failed:', error.message);
  }
}

testSMTP();
