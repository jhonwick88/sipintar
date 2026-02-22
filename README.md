# Walkthrough - Sistem Administrasi Surat Desa

A production-ready Village Letter Administration System built with Flutter and Firebase.

## Key Features Implemented

### 👤 User Flow (Anonymous)
- **Landing Page**: Modern grid layout showing available letter templates.
- **QR Flow**: Clicking a template generates a QR code. Scanning the QR opens the request form.
- **Dynamic Form**: Users input KTP/KK data which is saved as `pending` to Firestore.

### 👨💼 Admin & Dev Flow
- **Google Login**: Secure authentication for village staff.
- **Role Guard**: Access control for Admin and Dev roles.
- **Responsive Dashboard**:
  - **Web**: Sidebar NavigationRail.
  - **Mobile**: Bottom NavigationBar.
  - Real-time badges for pending requests.
- **Template Management**: Real `.docx` upload using `file_picker` and Firestore metadata.
- **Edit Before Approve**: Admins can edit user-submitted data directly in the dashboard before generating the final document.


### 📄 Approval Logic (Core Business)
- **Automatic Numbering**: Uses **Firestore Transaction** to prevent duplicate numbers.
  - Format: `140/{noUrut}/DS-SKM/{bulanRomawi}/{tahun}`
- **Docx Generation**: Generates the final letter in memory using the template and user data.
- **WhatsApp Integration**: Automatically redirects to WhatsApp with a pre-filled message (Approved/Rejected).

## Technical Implementation Highlights

- **Clean Architecture**: Separation of Data, Domain, and Presentation layers.
- **State Management**: Consistently used **Riverpod**.
- **Responsive UI**: Custom `ResponsiveLayout` and `MediaQuery` for adaptive grids.
- **Security**: Production-ready **Firestore Rules** restricting public read access.

## How to Run

1.  **Firebase Setup**:
    - Create a Firebase project.
    - Enable Google Auth, Firestore, and Storage.
    - Add `google-services.json` to `android/app/` and Firebase config to Web.
2.  **Initialize Proj**:
    ```bash
    flutter pub get
    flutter run
    ```

## Code Landmarks
- [lib/main.dart](file:///h:/FlutterProject/sipintar/lib/main.dart): App entry and entry point guard.
- [lib/features/surat/data/surat_repository_impl.dart](file:///h:/FlutterProject/sipintar/lib/features/surat/data/surat_repository_impl.dart): Logic for automatic numbering.
- [lib/core/utils/docx_helper.dart](file:///h:/FlutterProject/sipintar/lib/core/utils/docx_helper.dart): Docx generation from memory.
- [lib/shared/widgets/request_detail_dialog.dart](file:///h:/FlutterProject/sipintar/lib/shared/widgets/request_detail_dialog.dart): Main approval UI flow.
