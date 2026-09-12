import nodemailer from 'nodemailer';

export class EmailService {
  private static transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.ethereal.email',
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    auth: {
      user: process.env.SMTP_USER || 'ethereal.user@ethereal.email',
      pass: process.env.SMTP_PASS || 'ethereal_password',
    },
  });

  static async sendVerificationEmail(toEmail: string, otp: string) {
    try {
      const htmlContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #002244;">TravelGo Email Verification</h2>
          <p>Thank you for registering with TravelGo! Please use the following 6-digit OTP to verify your email address:</p>
          <h1 style="background: #F0F4F8; padding: 15px; text-align: center; font-size: 32px; letter-spacing: 5px; color: #0077CC; border-radius: 5px;">${otp}</h1>
          <p>This OTP is valid for 15 minutes.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="font-size: 12px; color: #888;">If you did not request this, please ignore this email.</p>
        </div>
      `;

      const info = await this.transporter.sendMail({
        from: '"TravelGo No-Reply" <noreply@travelgo.com>',
        to: toEmail,
        subject: 'TravelGo - Verify your Email Address',
        html: htmlContent,
      });

      console.log(`Verification email sent to ${toEmail}, messageId: ${info.messageId}`);
    } catch (error) {
      console.error(`Failed to send verification email to ${toEmail}:`, error);
      // Don't throw to prevent blocking the registration flow if SMTP fails during dev
    }
  }
}
