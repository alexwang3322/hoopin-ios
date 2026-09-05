import SwiftUI

struct DmcaView: View {
    var body: some View {
        LegalPageView(
            title: "Copyright / DMCA",
            intro: "How to report content you believe infringes your copyright, and how we respond.",
            sections: [
                .init(body: "Hoopin respects intellectual property rights and responds to clear notices of alleged copyright infringement under the Digital Millennium Copyright Act (DMCA). Run titles, descriptions, and profile bios are written by users — if you believe something posted on Hoopin infringes your copyright, you can submit a takedown notice."),
                .init(
                    title: "To file a notice, include:",
                    bullets: [
                        "A description of the copyrighted work you claim has been infringed.",
                        "The specific location within Hoopin of the material you claim is infringing.",
                        "Your name, address, phone number, and email address.",
                        "A statement that you have a good-faith belief that the use is not authorized by the copyright owner, its agent, or the law.",
                        "A statement, made under penalty of perjury, that the information in the notice is accurate and that you are the copyright owner or authorized to act on their behalf.",
                        "Your physical or electronic signature.",
                    ]
                ),
                .init(title: "Where to send it.", body: "Designated agent contact information to be added."),
                .init(title: "Counter-notification.", body: "If content you posted was removed and you believe it was removed in error, you may submit a counter-notification identifying the removed material and stating, under penalty of perjury, that you have a good-faith belief it was removed by mistake or misidentification."),
                .init(title: "Repeat infringers.", body: "We may suspend or terminate the accounts of users who are found to repeatedly infringe others' copyrights."),
            ]
        )
    }
}
