package ___PACKAGE___

import android.net.Uri
import android.provider.ContactsContract
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import com.qmobile.qmobiledatasync.utils.BaseInputControl
import com.qmobile.qmobiledatasync.utils.InputControl
import com.qmobile.qmobileui.activity.mainactivity.ActivityResultController
import com.qmobile.qmobileui.activity.mainactivity.MainActivity
import com.qmobile.qmobileui.ui.SnackbarHelper
import com.qmobile.qmobileui.utils.PermissionChecker

@InputControl
class EmailContact(private val view: View) : BaseInputControl {

    override val autocomplete: Boolean = false

    override fun getIconName(): String {
        return "alternate_email.xml"
    }
    
    private lateinit var outputCallback: (outputText: String) -> Unit

    private val contactEmailCallback: (contactUri: Uri?) -> Unit = { contactUri ->
        contactUri?.let {
            (view.context as MainActivity?)?.apply {
                contentResolver.query(contactUri, null, null, null, null)?.let { cursor ->
                    if (cursor.moveToFirst()) {
                        val contactIdIndex = cursor.getColumnIndex(ContactsContract.Contacts._ID)
                        val contactId = cursor.getString(contactIdIndex)
                        contentResolver.query(
                            ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                            null,
                            ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = " + contactId,
                            null,
                            null
                        )?.let { dataCursor ->
                            var found = false
                            while (dataCursor.moveToNext()) {
                                found = true
                                val emailIndex = dataCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA)
                                val email = dataCursor.getString(emailIndex)
                                outputCallback(email)
                                break
                            }
                            if (!found) {
                                SnackbarHelper.show(this, "No email found in contact")
                                outputCallback("")
                            }
                        }
                    }
                }
            }
        }
    }

    override fun process(inputValue: Any?, outputCallback: (output: Any) -> Unit) {
        (view.context as PermissionChecker?)?.askPermission(
            permission = android.Manifest.permission.READ_CONTACTS,
            rationale = "Permission required to read contacts"
        ) { isGranted ->
            if (isGranted) {
                this.outputCallback = outputCallback
                (view.context as ActivityResultController?)?.launch(
                    type = ActivityResultContracts.PickContact(),
                    input = null,
                    callback = contactEmailCallback
                )
            }
        }
    }
}
