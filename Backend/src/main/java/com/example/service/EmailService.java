package com.example.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    /**
     * ✅ Envoyer un code OTP à 6 chiffres
     */
    public void sendPasswordResetCode(String toEmail, String code, String userName) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("SmartLearn - Code de réinitialisation");

            String htmlContent = String.format("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                </head>
                <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px;">
                        <h2 style="color: #6C5CE7; margin-bottom: 20px;">🔐 Réinitialisation de mot de passe</h2>
                        
                        <p>Bonjour <strong>%s</strong>,</p>
                        
                        <p>Vous avez demandé la réinitialisation de votre mot de passe.</p>
                        
                        <p style="font-size: 16px; color: #2D3436;">Votre code de vérification est :</p>
                        
                        <div style="background-color: white; padding: 25px; border-radius: 12px; text-align: center; margin: 30px 0; border: 2px dashed #6C5CE7;">
                            <h1 style="color: #6C5CE7; font-size: 56px; letter-spacing: 15px; margin: 0; font-family: 'Courier New', monospace;">%s</h1>
                        </div>
                        
                        <p style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; border-radius: 5px; margin: 20px 0;">
                            ⏱️ Ce code est valide pendant <strong>1 heure</strong>.
                        </p>
                        
                        <p style="color: #666; font-size: 14px; margin-top: 20px;">
                            <strong>Instructions :</strong><br>
                            1. Ouvrez l'application SmartLearn<br>
                            2. Entrez ce code dans la page de vérification<br>
                            3. Créez votre nouveau mot de passe
                        </p>
                        
                        <p style="color: #666; font-size: 13px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
                            Si vous n'avez pas demandé cette réinitialisation, ignorez simplement cet email.
                        </p>
                        
                        <p style="color: #666; font-size: 13px;">
                            Cordialement,<br>
                            <strong>L'équipe SmartLearn</strong>
                        </p>
                    </div>
                </body>
                </html>
                """, userName, code);

            helper.setText(htmlContent, true);
            mailSender.send(message);

            System.out.println("✅ Email avec code OTP envoyé à : " + toEmail);
            System.out.println("🔢 Code: " + code);

        } catch (MessagingException e) {
            System.err.println("❌ Erreur lors de l'envoi de l'email : " + e.getMessage());
            throw new RuntimeException("Impossible d'envoyer l'email de réinitialisation");
        }
    }

    /**
     * Envoyer un email de confirmation après réinitialisation
     */
    public void sendPasswordChangedEmail(String toEmail, String userName) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("SmartLearn - Votre mot de passe a été modifié");

            String htmlContent = String.format("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                </head>
                <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px;">
                        <h2 style="color: #00b894; margin-bottom: 20px;">✅ Mot de passe modifié</h2>
                        
                        <p>Bonjour <strong>%s</strong>,</p>
                        
                        <p>Votre mot de passe a été modifié avec succès.</p>
                        
                        <p style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; border-radius: 5px; margin: 20px 0;">
                            ⚠️ Si vous n'êtes pas à l'origine de cette modification, 
                            veuillez contacter immédiatement notre support.
                        </p>
                        
                        <p style="color: #666; font-size: 13px; margin-top: 30px;">
                            Cordialement,<br>
                            <strong>L'équipe SmartLearn</strong>
                        </p>
                    </div>
                </body>
                </html>
                """, userName);

            helper.setText(htmlContent, true);
            mailSender.send(message);

        } catch (MessagingException e) {
            System.err.println("⚠️ Erreur lors de l'envoi de l'email de confirmation : " + e.getMessage());
        }
    }
}