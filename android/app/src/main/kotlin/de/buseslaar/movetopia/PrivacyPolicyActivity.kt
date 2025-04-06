package de.buseslaar.movetopia

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import de.buseslaar.movetopia.BuildConfig

/**
 * Activity to show privacy policy.
 * This activity is used as a target for the Health Connect app's
 * permission usage screen and automatically opens the privacy policy in the browser.
 */
class PrivacyPolicyActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Nutze die URL aus den BuildConfig-Feldern
        val privacyPolicyUrl = BuildConfig.PRIVACY_POLICY_URL

        // Open privacy policy in browser
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(privacyPolicyUrl))
        startActivity(intent)

        // Finish this activity after opening the browser
        finish()
    }
} 