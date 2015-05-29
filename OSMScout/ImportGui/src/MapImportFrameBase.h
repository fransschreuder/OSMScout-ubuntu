///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Jan 29 2014)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __MapImportFrameBase__
#define __MapImportFrameBase__

#include <wx/string.h>
#include <wx/filepicker.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/textctrl.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class MapImportFrameBase
///////////////////////////////////////////////////////////////////////////////
class MapImportFrameBase : public wxFrame 
{
	private:
	
	protected:
		wxFilePickerCtrl* m_filePickerSrc;
		wxButton* m_buttonStart;
		wxTextCtrl* m_Console;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnClose( wxCloseEvent& event ) { event.Skip(); }
		virtual void onStart( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		MapImportFrameBase( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("OSMScout Map Import tool"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 481,466 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~MapImportFrameBase();
	
};

#endif //__MapImportFrameBase__
