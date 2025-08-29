Codeunit 81183 "Prod. Order Change App. Mgmt"
{
    Description = 'T12149';
    trigger OnRun()
    begin
    end;

    var
        Text000_gCtx: label 'There is nothing to approve.';
        Text003_gCtx: label 'Approval entry created successfully.';
        Text004_gCtx: label 'Do you want to create approval entries?';
        Text005_gCtx: label 'Do you want to cancel approval entries?';
        Text006_gCtx: label 'Approval entry cancelled successfully.';
        Text007_gCtx: label 'Do you want to approve request?';
        Text008_gCtx: label 'Do you want to reject request?';
        Text009_gCtx: label 'There is nothing to reject.';
        Text010_gCtx: label 'There is nothing to show.';
        Text011_gCtx: label 'Do you want to re-open approval entries?';
        Text012_gCtx: label 'Approval entry opened successfully.';
        Text013_gCtx: label 'Entry is auto-approved.';
        Text016_gCtx: label 'There is nothing to approve.';
        Text017_gCtx: label 'Do you want to approve selected request lines?';
        Text018_gCtx: label 'Do you want to reject selected request lines?';
        Text019_gCtx: label 'There is nothing to reject.';
        ApprovalsDelegatedMsg: label 'The selected approval requests have been delegated.';
        DelegateOnlyOpenRequestsErr: label 'You can only delegate open approval requests.';
        ApproverUserIdNotInSetupErr: label 'You must set up an approver for user ID %1 in the Approval User Setup window.', Comment = 'You must set up an approver for user ID NAVUser in the Approval User Setup window.';
        CustomUrlAndAnchorTxt: label '(<a href="%1">Click Here to Approve</a>)';


    procedure SendForApproval_gFnc(var ProdOrderChangeNoteHdr_vRec: Record "Prod. Order Change Note Header")
    var
        UserAppLevel_lRec: Record "Adv_User Approver Sequence";
        ProdOrderChangeNoteLines_lRec: Record "Prod. Order Change Note Line";
        Text5000_lCtx: label 'There is no component lines for post document No. : %1';
        ProdOrderLine_lRec: Record "Prod. Order Line";
        SubstituteApproval_lBln: Boolean;
        CatApproverUserID_lCod: Code[50];
        Item_lRec: Record Item;
        ItemCategory_lRec: Record "Item Category";
        AutoApprove_lBln: Boolean;
        SubAppEnable_lBln: Boolean;
        Adv_UserApprovalEntry: Record "Adv_User Approval Entry";
    begin
        if ProdOrderChangeNoteHdr_vRec."Base Prod. BOM Change Note" then begin
            ProdOrderChangeNoteHdr_vRec."Approved By" := UserId;
            ProdOrderChangeNoteHdr_vRec."Approved On" := Today;
            ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."change status"::Approved;
            ProdOrderChangeNoteHdr_vRec.Modify;

            Message(Text013_gCtx);
        end else begin
            ProdOrderChangeNoteHdr_vRec.TestField("No.");
            ProdOrderChangeNoteHdr_vRec.TestField("Change Status", ProdOrderChangeNoteHdr_vRec."change status"::Open);

            //Update Validate Qty Per
            if ProdOrderChangeNoteHdr_vRec."Total Raw Material to Consume" <> 0 then begin
                ProdOrderChangeNoteLines_lRec.Reset;
                ProdOrderChangeNoteLines_lRec.SetRange(ProdOrderChangeNoteLines_lRec."Document No.", ProdOrderChangeNoteHdr_vRec."No.");
                if ProdOrderChangeNoteLines_lRec.FindSet then begin
                    repeat
                        ProdOrderChangeNoteLines_lRec."Final Qty. Per" := 0;
                        if ProdOrderChangeNoteLines_lRec.Action <> ProdOrderChangeNoteLines_lRec.Action::Delete then begin
                            if ProdOrderChangeNoteLines_lRec."New Expected Quantity" <> 0 then
                                ProdOrderChangeNoteLines_lRec."Final Qty. Per" := ProdOrderChangeNoteLines_lRec."New Expected Quantity" / ProdOrderChangeNoteHdr_vRec."Total Raw Material to Consume"
                            else
                                ProdOrderChangeNoteLines_lRec."Final Qty. Per" := ProdOrderChangeNoteLines_lRec."Expected Quantity" / ProdOrderChangeNoteHdr_vRec."Total Raw Material to Consume"
                        end;
                        ProdOrderChangeNoteLines_lRec.Modify;
                    until ProdOrderChangeNoteLines_lRec.Next = 0;
                end;
                Commit;
            end;

            SubstituteApproval_lBln := false;
            AutoApprove_lBln := true;
            CatApproverUserID_lCod := '';
            ProdOrderChangeNoteLines_lRec.Reset;
            ProdOrderChangeNoteLines_lRec.SetRange(ProdOrderChangeNoteLines_lRec."Document No.", ProdOrderChangeNoteHdr_vRec."No.");
            ProdOrderChangeNoteLines_lRec.SetFilter(Action, '<>%1', ProdOrderChangeNoteLines_lRec.Action::" ");
            if not ProdOrderChangeNoteLines_lRec.FindSet then begin
                Error(Text5000_lCtx, ProdOrderChangeNoteHdr_vRec."No.");
            end else begin
                repeat
                    SubAppEnable_lBln := false;
                    if ProdOrderChangeNoteLines_lRec."Substitute Selected" then
                        SubAppEnable_lBln := true;

                    //T10752-NS
                    if ProdOrderChangeNoteLines_lRec.Action = ProdOrderChangeNoteLines_lRec.Action::Add then begin
                        if (not ProdOrderChangeNoteLines_lRec.Recovery) and (not ProdOrderChangeNoteLines_lRec."FG Recovery") then
                            SubAppEnable_lBln := true;
                    end;
                    //T10752-NE

                    // if SubAppEnable_lBln then begin
                    //     SubstituteApproval_lBln := true;
                    //     ProdOrderLine_lRec.Get(ProdOrderChangeNoteHdr_vRec."Prod. Order Status", ProdOrderChangeNoteHdr_vRec."Prod. Order No.", ProdOrderChangeNoteHdr_vRec."Prod. Order Line No.");
                    //     Item_lRec.Get(ProdOrderLine_lRec."Item No.");
                    //     Item_lRec.TestField("Item Category Code");
                    //     ItemCategory_lRec.Get(Item_lRec."Item Category Code");
                    //     ItemCategory_lRec.TestField("Substitute Approver");
                    //     CatApproverUserID_lCod := ItemCategory_lRec."Substitute Approver";
                    // end;

                    if ProdOrderChangeNoteLines_lRec."Out of Tolerance" or ProdOrderChangeNoteLines_lRec."Item Variant Changed" or ProdOrderChangeNoteLines_lRec."Substitute Selected" then
                        AutoApprove_lBln := false;
                until ProdOrderChangeNoteLines_lRec.Next = 0;
            end;

            if ProdOrderChangeNoteHdr_vRec."Prod Qty Change Type" = ProdOrderChangeNoteHdr_vRec."Prod Qty Change Type"::Reduced then begin
                CheckQtyPerSum_gFnc(ProdOrderChangeNoteHdr_vRec);
                CheckToPrincipleInputQtyPerSum_gFnc(ProdOrderChangeNoteHdr_vRec);
            end;


            if AutoApprove_lBln then begin
                ProdOrderChangeNoteHdr_vRec.Approve := true;
                ProdOrderChangeNoteHdr_vRec."Approved By" := UserId;
                ProdOrderChangeNoteHdr_vRec."Approved On" := Today;
                ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."change status"::Approved;
                ProdOrderChangeNoteHdr_vRec.Modify;
                Message('Change Note %1 is auto approved', ProdOrderChangeNoteHdr_vRec."No.");
                exit;
            end;

            if not Confirm(Text004_gCtx, true) then
                exit;

            if SubstituteApproval_lBln then begin
                CreateApprovalEntryCatApprover_lFnc(ProdOrderChangeNoteHdr_vRec, CatApproverUserID_lCod);
            end else begin
                UserAppLevel_lRec.Reset;
                UserAppLevel_lRec.SetCurrentkey("Approval Source", "Source UserID", Sequence);
                UserAppLevel_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
                UserAppLevel_lRec.SetRange("Source UserID", UserId);
                UserAppLevel_lRec.SetFilter("Approver UserID", '<>%1', '');
                if UserAppLevel_lRec.IsEmpty then begin
                    //ProdOrderChangeNoteHdr_vRec."Approved By" := USERID;
                    //ProdOrderChangeNoteHdr_vRec."Approved On" := TODAY;
                    //ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."Change Status"::Approved;
                    //ProdOrderChangeNoteHdr_vRec.MODIFY;
                    //
                    //MESSAGE(Text013_gCtx);
                    //EXIT;
                    Error('Production Order Change Note Approver not found for User ID %1', UserId);
                end;

                if UserAppLevel_lRec.FindSet then begin
                    repeat
                        CreateApprovalEntry_lFnc(ProdOrderChangeNoteHdr_vRec, UserAppLevel_lRec);
                    until UserAppLevel_lRec.Next = 0;
                end;
            end;

            OpenFirstEntry_lFnc(ProdOrderChangeNoteHdr_vRec);

            Adv_UserApprovalEntry.Reset;
            Adv_UserApprovalEntry.SetRange("Approval Source", "Approval Source"::"Production Change Note");
            Adv_UserApprovalEntry.SetRange("Prod. Order Change Note No.", ProdOrderChangeNoteHdr_vRec."No.");
            Adv_UserApprovalEntry.SetRange("Prod. Order Status", ProdOrderChangeNoteHdr_vRec."Prod. Order Status");
            Adv_UserApprovalEntry.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_vRec."Prod. Order No.");
            Adv_UserApprovalEntry.SetRange("Prod. Order Line No.", ProdOrderChangeNoteHdr_vRec."Prod. Order Line No.");
            Adv_UserApprovalEntry.SetRange("Requester ID", ProdOrderChangeNoteHdr_vRec."Created By");
            Adv_UserApprovalEntry.SetRange("Requester Sent Date", ProdOrderChangeNoteHdr_vRec."Created On");
            Adv_UserApprovalEntry.SetFilter("Line Status", '%1|%2', Adv_UserApprovalEntry."Line Status"::Created, Adv_UserApprovalEntry."Line Status"::Open);
            if Adv_UserApprovalEntry.FindFirst then begin
                ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."change status"::Submitted;
                ProdOrderChangeNoteHdr_vRec.Submitted := true;
                ProdOrderChangeNoteHdr_vRec."Submitted By" := UserId;
                ProdOrderChangeNoteHdr_vRec."Submitted On" := Today;
                ProdOrderChangeNoteHdr_vRec.Modify;
                Message(Text003_gCtx);
            end;

        end;
    end;


    procedure CancelApprovalRequest_gFnc(var ProdOrderChangeNoteHdr_vRec: Record "Prod. Order Change Note Header")
    begin
        ProdOrderChangeNoteHdr_vRec.TestField("Change Status", ProdOrderChangeNoteHdr_vRec."change status"::Submitted);
        if not Confirm(Text005_gCtx, false) then
            exit;

        CancelApprovalEntry_lFnc(ProdOrderChangeNoteHdr_vRec);

        ProdOrderChangeNoteHdr_vRec.Submitted := false;
        ProdOrderChangeNoteHdr_vRec."Submitted By" := '';
        ProdOrderChangeNoteHdr_vRec."Submitted On" := 0D;
        ProdOrderChangeNoteHdr_vRec.Approve := false;
        ProdOrderChangeNoteHdr_vRec."Approved By" := '';
        ProdOrderChangeNoteHdr_vRec."Approved On" := 0D;
        ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."change status"::Open;
        ProdOrderChangeNoteHdr_vRec.Modify;

        Message(Text006_gCtx);
    end;


    procedure ReOpenRequest_gFnc(var ProdOrderChangeNoteHdr_vRec: Record "Prod. Order Change Note Header")
    begin
        if ProdOrderChangeNoteHdr_vRec."Change Status" = ProdOrderChangeNoteHdr_vRec."change status"::Open then
            exit;

        if ProdOrderChangeNoteHdr_vRec."Change Status" = ProdOrderChangeNoteHdr_vRec."change status"::Posted then
            exit;

        if ProdOrderChangeNoteHdr_vRec."Change Status" in [ProdOrderChangeNoteHdr_vRec."change status"::Approved, ProdOrderChangeNoteHdr_vRec."change status"::Submitted] then begin
            if not Confirm(Text011_gCtx, false) then
                exit;
        end else
            ProdOrderChangeNoteHdr_vRec.FieldError("Change Status");

        CancelApprovalEntry_lFnc(ProdOrderChangeNoteHdr_vRec);

        ProdOrderChangeNoteHdr_vRec.Submitted := false;
        ProdOrderChangeNoteHdr_vRec."Submitted By" := '';
        ProdOrderChangeNoteHdr_vRec."Submitted On" := 0D;
        ProdOrderChangeNoteHdr_vRec.Approve := false;
        ProdOrderChangeNoteHdr_vRec."Approved By" := '';
        ProdOrderChangeNoteHdr_vRec."Approved On" := 0D;
        ProdOrderChangeNoteHdr_vRec."Change Status" := ProdOrderChangeNoteHdr_vRec."change status"::Open;
        ProdOrderChangeNoteHdr_vRec.Modify;

        Message(Text012_gCtx);
    end;


    procedure ApproveSelectedEntry_gFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        UserAppEntry_lRec.Copy(UserAppEntry_vRec);

        if not Confirm(Text017_gCtx, false) then
            exit;

        UserAppEntry_lRec.SetRange(Select, true);
        if UserAppEntry_lRec.FindSet then begin
            repeat
                ApproveEntry_gFnc(UserAppEntry_lRec, false);
            until UserAppEntry_lRec.Next = 0;
        end else begin
            Message(Text016_gCtx);
            exit;
        end;
    end;


    procedure ApproveEntry_gFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        FirstUserAppEntry_lRec: Record "Adv_User Approval Entry";
        ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
    begin
        if ShowConfirm_iBln then begin
            if not Confirm(Text007_gCtx, false) then
                exit;
        end;

        UserAppEntry_vRec."Line Status" := UserAppEntry_vRec."Line Status"::Approved;
        UserAppEntry_vRec."Approver Response Receive On" := CurrentDatetime;
        UserAppEntry_vRec.Modify(true);

        FirstUserAppEntry_lRec.Reset;
        FirstUserAppEntry_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Change Note No.", UserAppEntry_vRec."Prod. Order Change Note No.");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Status", UserAppEntry_vRec."Prod. Order Status");
        FirstUserAppEntry_lRec.SetRange("Prod. Order No.", UserAppEntry_vRec."Prod. Order No.");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Line No.", UserAppEntry_vRec."Prod. Order Line No.");
        FirstUserAppEntry_lRec.SetRange("Requester ID", UserAppEntry_vRec."Requester ID");
        FirstUserAppEntry_lRec.SetRange("Requester Sent Date", UserAppEntry_vRec."Requester Sent Date");
        FirstUserAppEntry_lRec.SetRange("Line Status", UserAppEntry_vRec."Line Status"::Created);
        if FirstUserAppEntry_lRec.FindFirst then begin
            FirstUserAppEntry_lRec."Line Status" := FirstUserAppEntry_lRec."Line Status"::Open;
            NewSendEmail_gFnc(FirstUserAppEntry_lRec);
            FirstUserAppEntry_lRec.Modify;
            exit;
        end;

        ProdOrderChangeNoteHdr_lRec.SetRange("No.", UserAppEntry_vRec."Prod. Order Change Note No.");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Status", UserAppEntry_vRec."Prod. Order Status");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order No.", UserAppEntry_vRec."Prod. Order No.");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Line No.", UserAppEntry_vRec."Prod. Order Line No.");
        ProdOrderChangeNoteHdr_lRec.FindFirst;

        ProdOrderChangeNoteHdr_lRec.Approve := true;
        ProdOrderChangeNoteHdr_lRec."Approved By" := UserId;
        ProdOrderChangeNoteHdr_lRec."Approved On" := Today;
        ProdOrderChangeNoteHdr_lRec."Change Status" := ProdOrderChangeNoteHdr_lRec."change status"::Approved;

        ProdOrderChangeNoteHdr_lRec.Modify;
        NewApprovedSendEmail_gFnc(UserAppEntry_vRec);
    end;


    procedure RejectSelectedEntry_gFnc(var SelUserAppEntry_vRec: Record "Adv_User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        UserAppEntry_lRec.Copy(SelUserAppEntry_vRec);

        if not Confirm(Text018_gCtx, false) then
            exit;

        UserAppEntry_lRec.SetRange(Select, true);
        if UserAppEntry_lRec.FindSet then begin
            repeat
                RejectEntry_gFnc(UserAppEntry_lRec, false);
            until UserAppEntry_lRec.Next = 0;
        end else begin
            Message(Text019_gCtx);
            exit;
        end;
    end;


    procedure RejectEntry_gFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        FirstUserAppEntry_lRec: Record "Adv_User Approval Entry";
        ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
    begin
        if ShowConfirm_iBln then begin
            if not Confirm(Text008_gCtx, false) then
                exit;
        end;

        UserAppEntry_vRec.TestField(Remarks);
        UserAppEntry_vRec."Line Status" := UserAppEntry_vRec."Line Status"::Rejected;
        UserAppEntry_vRec."Approver Response Receive On" := CurrentDatetime;
        UserAppEntry_vRec.Modify(true);

        FirstUserAppEntry_lRec.Reset;
        FirstUserAppEntry_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Change Note No.", UserAppEntry_vRec."Prod. Order Change Note No.");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Status", UserAppEntry_vRec."Prod. Order Status");
        FirstUserAppEntry_lRec.SetRange("Prod. Order No.", UserAppEntry_vRec."Prod. Order No.");
        FirstUserAppEntry_lRec.SetRange("Prod. Order Line No.", UserAppEntry_vRec."Prod. Order Line No.");
        FirstUserAppEntry_lRec.SetRange("Requester ID", UserAppEntry_vRec."Requester ID");
        FirstUserAppEntry_lRec.SetRange("Requester Sent Date", UserAppEntry_vRec."Requester Sent Date");
        FirstUserAppEntry_lRec.SetRange("Line Status", UserAppEntry_vRec."Line Status"::Created);
        if FirstUserAppEntry_lRec.FindSet then begin
            repeat
                FirstUserAppEntry_lRec."Line Status" := FirstUserAppEntry_lRec."Line Status"::Cancelled;
                FirstUserAppEntry_lRec.Modify;
            until FirstUserAppEntry_lRec.Next = 0;
        end;

        ProdOrderChangeNoteHdr_lRec.SetRange("No.", UserAppEntry_vRec."Prod. Order Change Note No.");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Status", UserAppEntry_vRec."Prod. Order Status");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order No.", UserAppEntry_vRec."Prod. Order No.");
        ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Line No.", UserAppEntry_vRec."Prod. Order Line No.");
        ProdOrderChangeNoteHdr_lRec.FindFirst;


        ProdOrderChangeNoteHdr_lRec."Change Status" := ProdOrderChangeNoteHdr_lRec."change status"::Open;
        ProdOrderChangeNoteHdr_lRec.Modify;
        NewRejectedSendEmail_gFnc(UserAppEntry_vRec);    //RejectedMail-N
    end;

    local procedure CreateApprovalEntry_lFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header"; UserAppLevel_iRec: Record "Adv_User Approver Sequence")
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        Clear(UserAppEntry_lRec);
        UserAppEntry_lRec.Init;
        UserAppEntry_lRec."Approval Source" := UserAppEntry_lRec."Approval Source"::"Production Change Note";
        UserAppEntry_lRec."Entry No." := GetLastEntryNo_gFnc('PRODORDER_CHANGE_NOTE');
        UserAppEntry_lRec."Prod. Order Change Note No." := ProdOrderChangeNoteHdr_iRec."No.";
        UserAppEntry_lRec."Prod. Order Status" := ProdOrderChangeNoteHdr_iRec."Prod. Order Status";
        UserAppEntry_lRec."Prod. Order No." := ProdOrderChangeNoteHdr_iRec."Prod. Order No.";
        UserAppEntry_lRec."Prod. Order Line No." := ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.";
        UserAppEntry_lRec."Requester ID" := ProdOrderChangeNoteHdr_iRec."Created By";
        UserAppEntry_lRec."Requester Sent Date" := ProdOrderChangeNoteHdr_iRec."Created On";
        UserAppEntry_lRec."Approver ID" := UserAppLevel_iRec."Approver UserID";
        UserAppEntry_lRec."Approval level" := UserAppLevel_iRec.Sequence;
        UserAppEntry_lRec."Line Status" := UserAppEntry_lRec."Line Status"::Created;
        UserAppEntry_lRec."Approval Request Send On" := CurrentDatetime;
        UserAppEntry_lRec.Insert(true);
    end;

    local procedure CreateApprovalEntryCatApprover_lFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header"; ApproverID_iCod: Code[50])
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        Clear(UserAppEntry_lRec);
        UserAppEntry_lRec.Init;
        UserAppEntry_lRec."Approval Source" := UserAppEntry_lRec."Approval Source"::"Production Change Note";
        UserAppEntry_lRec."Entry No." := GetLastEntryNo_gFnc('PRODORDER_CHANGE_NOTE');
        UserAppEntry_lRec."Prod. Order Change Note No." := ProdOrderChangeNoteHdr_iRec."No.";
        UserAppEntry_lRec."Prod. Order Status" := ProdOrderChangeNoteHdr_iRec."Prod. Order Status";
        UserAppEntry_lRec."Prod. Order No." := ProdOrderChangeNoteHdr_iRec."Prod. Order No.";
        UserAppEntry_lRec."Prod. Order Line No." := ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.";
        UserAppEntry_lRec."Requester ID" := ProdOrderChangeNoteHdr_iRec."Created By";
        UserAppEntry_lRec."Requester Sent Date" := ProdOrderChangeNoteHdr_iRec."Created On";
        UserAppEntry_lRec."Approver ID" := ApproverID_iCod;
        UserAppEntry_lRec."Approval level" := 0;
        UserAppEntry_lRec."Line Status" := UserAppEntry_lRec."Line Status"::Created;
        UserAppEntry_lRec."Approval Request Send On" := CurrentDatetime;
        UserAppEntry_lRec.Insert(true);
    end;

    local procedure OpenFirstEntry_lFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
        UserAppEntry_lRec.SetRange("Prod. Order Change Note No.", ProdOrderChangeNoteHdr_iRec."No.");
        UserAppEntry_lRec.SetRange("Prod. Order Status", ProdOrderChangeNoteHdr_iRec."Prod. Order Status");
        UserAppEntry_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_iRec."Prod. Order No.");
        UserAppEntry_lRec.SetRange("Prod. Order Line No.", ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.");
        UserAppEntry_lRec.SetRange("Requester ID", ProdOrderChangeNoteHdr_iRec."Created By");
        UserAppEntry_lRec.SetRange("Requester Sent Date", ProdOrderChangeNoteHdr_iRec."Created On");
        UserAppEntry_lRec.SetRange("Line Status", UserAppEntry_lRec."Line Status"::Created);
        UserAppEntry_lRec.FindFirst;
        if UserAppEntry_lRec."Requester ID" = UserAppEntry_lRec."Approver ID" then
            ApproveEntry_gFnc(UserAppEntry_lRec, true)
        else
            UserAppEntry_lRec."Line Status" := UserAppEntry_lRec."Line Status"::Open;
        NewSendEmail_gFnc(UserAppEntry_lRec);
        UserAppEntry_lRec.Modify;
    end;

    local procedure CancelApprovalEntry_lFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        //Cancel status=Created & Open entry
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
        UserAppEntry_lRec.SetRange("Prod. Order Change Note No.", ProdOrderChangeNoteHdr_iRec."No.");
        UserAppEntry_lRec.SetRange("Prod. Order Status", ProdOrderChangeNoteHdr_iRec."Prod. Order Status");
        UserAppEntry_lRec.SetRange("Prod. Order No.", ProdOrderChangeNoteHdr_iRec."Prod. Order No.");
        UserAppEntry_lRec.SetRange("Prod. Order Line No.", ProdOrderChangeNoteHdr_iRec."Prod. Order Line No.");
        UserAppEntry_lRec.SetRange("Requester ID", ProdOrderChangeNoteHdr_iRec."Created By");
        UserAppEntry_lRec.SetRange("Requester Sent Date", ProdOrderChangeNoteHdr_iRec."Created On");
        UserAppEntry_lRec.SetRange("Line Status", UserAppEntry_lRec."Line Status"::Created);
        UserAppEntry_lRec.SetFilter("Line Status", '%1|%2', UserAppEntry_lRec."Line Status"::Created, UserAppEntry_lRec."Line Status"::Open);
        UserAppEntry_lRec.ModifyAll("Line Status", UserAppEntry_lRec."Line Status"::Cancelled, true);
    end;


    procedure DelegateApprovalRequests_gFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry")
    begin
        if UserAppEntry_vRec.FindSet(true) then begin
            repeat
                DelegateSelectedApprovalRequest_gFnc(UserAppEntry_vRec, true);
            until UserAppEntry_vRec.Next = 0;
            Message(ApprovalsDelegatedMsg);
        end;
    end;


    procedure DelegateSelectedApprovalRequest_gFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry"; CheckCurrentUser: Boolean)
    begin
        if UserAppEntry_vRec."Line Status" <> UserAppEntry_vRec."Line Status"::Open then
            Error(DelegateOnlyOpenRequestsErr);

        if CheckCurrentUser then
            if not (UserId in [UserAppEntry_vRec."Requester ID", UserAppEntry_vRec."Approver ID"]) then
                CheckUserAsApprovalAdministrator_lFnc;

        SubstituteUserIdForApprovalEntry_lFnc(UserAppEntry_vRec)
    end;

    local procedure CheckUserAsApprovalAdministrator_lFnc()
    var
        UserSetup_lRec: Record "User Setup";
    begin
        UserSetup_lRec.Get(UserId);
        UserSetup_lRec.TestField("Approval Administrator");
    end;

    local procedure SubstituteUserIdForApprovalEntry_lFnc(var UserAppEntry_vRec: Record "Adv_User Approval Entry")
    var
        UserSetup_lRec: Record "User Setup";
        ApprovalAdminUserSetup: Record "User Setup";
    begin
        if not UserSetup_lRec.Get(UserAppEntry_vRec."Approver ID") then
            Error(ApproverUserIdNotInSetupErr, UserAppEntry_vRec."Requester ID");

        UserSetup_lRec.TestField(Substitute);

        UserAppEntry_vRec."Approver ID" := UserSetup_lRec.Substitute;
        UserAppEntry_vRec."Entry Substituted" := true;
        UserAppEntry_vRec.Modify(true);
    end;

    local procedure "<<<<Other>>>>"()
    begin
    end;


    procedure SetStyle_lFnc(UserAppEntry_iRec: Record "Adv_User Approval Entry"): Text
    begin
        case UserAppEntry_iRec."Line Status" of
            UserAppEntry_iRec."Line Status"::Open:
                exit('Favorable');
            UserAppEntry_iRec."Line Status"::Cancelled:
                exit('Subordinate');
            UserAppEntry_iRec."Line Status"::Rejected:
                exit('Unfavorable');
            else
                exit('Standard')
        end
    end;


    procedure GetLastEntryNo_gFnc(Type_iTxt: Text[50]): Integer
    var
        UserAppEntry_lRec: Record "Adv_User Approval Entry";
    begin
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange("Approval Source", UserAppEntry_lRec."Approval Source"::"Production Change Note");
        if UserAppEntry_lRec.FindLast then
            exit(UserAppEntry_lRec."Entry No." + 1)
        else
            exit(1);
    end;


    procedure "---------------CreateNegativeConsumptionEntry---------------"()
    begin
    end;


    procedure CreateNegativeConsumptionEntry_gFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
        ItemJnlLine_lRec: Record "Item Journal Line";
        ItemLedgEntry_lRec: Record "Item Ledger Entry";
        ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        QtyForNegativeConsumption_lDec: Decimal;
        RemQtyForNegativeConsumption_lDec: Decimal;
        ILERemQty_lDec: Decimal;
        DefaultDimension_lRec: Record "Default Dimension";
        TmpDimensionSetEntry_lRecTmp: Record "Dimension Set Entry" temporary;
        DimensionChangesMgt_lCdu: Codeunit "Dimension Change Mgmt";
    begin
        //CreateNegativeConsumptionEntry-NS 12-09-17

        ProdOrderChangeNoteHdr_iRec.TestField("Change Status", ProdOrderChangeNoteHdr_iRec."change status"::Approved);

        Clear(ManufacturingSetup_lRec);
        ManufacturingSetup_lRec.Get;
        ManufacturingSetup_lRec.TestField("Item Templete - Con. Neg. Adj.");
        ManufacturingSetup_lRec.TestField("Item Batch - Con. Neg. Adj.");

        ItemJnlLine_lRec.Reset;
        ItemJnlLine_lRec.SetRange("Journal Template Name", ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.");
        ItemJnlLine_lRec.SetRange("Journal Batch Name", ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
        ItemJnlLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_iRec."No.");
        if ItemJnlLine_lRec.FindFirst then
            Error('Reverse Consumption Line already Create for Document %1. Please delete existing lines first', ProdOrderChangeNoteLine_lRec."Document No.");

        ProdOrderChangeNoteLine_lRec.Reset;
        ProdOrderChangeNoteLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_iRec."No.");
        ProdOrderChangeNoteLine_lRec.SetRange(Action, ProdOrderChangeNoteLine_lRec.Action::Modify);
        if ProdOrderChangeNoteLine_lRec.FindSet then begin
            repeat
                QtyForNegativeConsumption_lDec := 0;
                ProdOrderChangeNoteLine_lRec.CalcFields("Act. Consumption (Qty)");
                QtyForNegativeConsumption_lDec := ProdOrderChangeNoteLine_lRec."Act. Consumption (Qty)" - ProdOrderChangeNoteLine_lRec."New Expected Quantity";
                RemQtyForNegativeConsumption_lDec := QtyForNegativeConsumption_lDec;
                if QtyForNegativeConsumption_lDec > 0 then begin
                    ItemLedgEntry_lRec.Reset;
                    ItemLedgEntry_lRec.SetRange("Entry Type", ItemLedgEntry_lRec."entry type"::Consumption);
                    ItemLedgEntry_lRec.SetRange("Order Type", ItemLedgEntry_lRec."order type"::Production);
                    ItemLedgEntry_lRec.SetRange("Order No.", ProdOrderChangeNoteLine_lRec."Prod. Order No.");
                    ItemLedgEntry_lRec.SetRange("Order Line No.", ProdOrderChangeNoteLine_lRec."Prod. Order Line No.");
                    ItemLedgEntry_lRec.SetRange("Prod. Order Comp. Line No.", ProdOrderChangeNoteLine_lRec."Prod. Order Component Line No.");
                    ItemLedgEntry_lRec.SetRange("Item No.", ProdOrderChangeNoteLine_lRec."Item No.");
                    ItemLedgEntry_lRec.SetFilter("Shipped Qty. Not Returned", '<>%1', 0);
                    if ItemLedgEntry_lRec.FindSet then begin
                        repeat
                            ItemJnlLine_lRec.Init;
                            ItemJnlLine_lRec."Journal Template Name" := ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.";
                            ItemJnlLine_lRec."Journal Batch Name" := ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.";
                            ItemJnlLine_lRec."Line No." := GetLastLineNo_lFnc(ItemJnlLine_lRec."Journal Template Name", ItemJnlLine_lRec."Journal Batch Name");
                            ItemJnlLine_lRec."Document No." := ProdOrderChangeNoteLine_lRec."Document No.";
                            ItemJnlLine_lRec.Validate("Entry Type", ItemJnlLine_lRec."entry type"::Consumption);
                            ItemJnlLine_lRec.Validate("Order No.", ItemLedgEntry_lRec."Order No.");
                            ItemJnlLine_lRec.Validate("Source No.", ItemLedgEntry_lRec."Source No.");
                            ItemJnlLine_lRec.Validate("Posting Date", Today);
                            ItemJnlLine_lRec.Validate("Item No.", ItemLedgEntry_lRec."Item No.");
                            ItemJnlLine_lRec.Validate("Unit of Measure Code", ItemLedgEntry_lRec."Unit of Measure Code");
                            ItemJnlLine_lRec.Description := ItemLedgEntry_lRec.Description;

                            //CalCulation For Quantity of negative cousumption -> NS

                            //1) Case 1:
                            //RemQtyForNegativeConsumption_lDec = 10
                            //ItemLedgEntry_lRec.Quantity = 40  (Multiple ILE find but in 1st ILE line there is sufficient qty)
                            //Consumption Jnl QTy = 10
                            //New RemQtyForNegativeConsumption_lDec = 0  ---> System will exit from loop as there is no remaining qty for negative consumption

                            //2) Case 2:
                            //RemQtyForNegativeConsumption_lDec = 10
                            //ItemLedgEntry1_lRec.Quantity = 5  (Multiple ILE find. In 1st line Qty = 5 and "Shipped Qty. Not Returned" = 5)
                            //ItemLedgEntry2_lRec.Quantity = 5  (Multiple ILE find. In 2nd line Qty = 5 and "Shipped Qty. Not Returned" = 5)
                            //ItemLedgEntry3_lRec.Quantity = 5  (Multiple ILE find. In 3rd line Qty = 5 and "Shipped Qty. Not Returned" = 5)
                            //In this case 2 negative consumption line will be created.
                            //1st negative consumption line calculation.
                            //ILERemQty_lDec = ABS(ItemLedgEntry_lRec."Shipped Qty. Not Returned") = (5);
                            //IF ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec THEN Begin   //5 >= 10 ---> Condition not statisfied so System runs below else part
                            //1st negative consumption line Qty. = 5 (System runs below else part)
                            //New RemQtyForNegativeConsumption_lDec = 5
                            //2nd negative consumption line calculation.
                            //IF ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec THEN Begin   //5 >= 5 ---> Condition statisfied so System runs above else part
                            //2nd negative consumption line Qty. = 5 (System runs above else part)
                            //New RemQtyForNegativeConsumption_lDec = 0  ---> System will exit from loop as there is no remaining qty for negative consumption

                            //3) Case 3:
                            //RemQtyForNegativeConsumption_lDec = 10
                            //ItemLedgEntry1_lRec.Quantity = 5  (Multiple ILE find. In 1st line Qty = 5 and "Shipped Qty. Not Returned" = 5)
                            //ItemLedgEntry2_lRec.Quantity = 5  (Multiple ILE find. In 2nd line Qty = 5 and "Shipped Qty. Not Returned" = 4)
                            //ItemLedgEntry3_lRec.Quantity = 5  (Multiple ILE find. In 3rd line Qty = 5 and "Shipped Qty. Not Returned" = 5)
                            //In this case 3 negative consumption line will be created.
                            //1st negative consumption line calculation.
                            //ILERemQty_lDec = ABS(ItemLedgEntry_lRec."Shipped Qty. Not Returned") = (5);
                            //IF ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec THEN Begin   //5 >= 10 ---> Condition not statisfied so System runs below else part
                            //1st negative consumption line Qty. = 5 (System runs below else part)
                            //New RemQtyForNegativeConsumption_lDec = 5
                            //2nd negative consumption line calculation.
                            //ILERemQty_lDec =ABS(ItemLedgEntry_lRec."Shipped Qty. Not Returned") = (4);
                            //ILERemQty_lDec = 1
                            //IF ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec THEN Begin   //4 >= 5 ---> Condition statisfied so System runs below else part
                            //2nd negative consumption line Qty. = 4 (System runs below else part)
                            //New RemQtyForNegativeConsumption_lDec = 1
                            //3rd negative consumption line calculation.
                            //ILERemQty_lDec = ABS(ItemLedgEntry_lRec."Shipped Qty. Not Returned") = (5);
                            //ILERemQty_lDec = 5
                            //IF ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec THEN Begin   //5 >= 1 ---> Condition statisfied so System runs above else part
                            //3rd negative consumption line Qty. = 1 (System runs above else part)
                            //New RemQtyForNegativeConsumption_lDec = 0  ---> System will exit from loop as there is no remaining qty for negative consumption

                            ILERemQty_lDec := Abs(ItemLedgEntry_lRec."Shipped Qty. Not Returned");
                            if ILERemQty_lDec >= RemQtyForNegativeConsumption_lDec then begin
                                ItemJnlLine_lRec.Validate(Quantity, RemQtyForNegativeConsumption_lDec);
                                RemQtyForNegativeConsumption_lDec := 0;
                            end else begin
                                ItemJnlLine_lRec.Validate(Quantity, ILERemQty_lDec);
                                RemQtyForNegativeConsumption_lDec -= ILERemQty_lDec;
                            end;
                            ItemJnlLine_lRec.Validate(Quantity, ItemJnlLine_lRec.Quantity * (-1));
                            //CalCulation For Quantity of negative cousumption <- NE

                            ItemJnlLine_lRec."Variant Code" := ItemLedgEntry_lRec."Variant Code";
                            if CheckITemTrackingItem_lFnc(ItemLedgEntry_lRec."Item No.") then begin
                                ItemJnlLine_lRec.Validate(ItemJnlLine_lRec."Serial No.", ItemLedgEntry_lRec."Serial No.");
                                ItemJnlLine_lRec.Validate(ItemJnlLine_lRec."Lot No.", ItemLedgEntry_lRec."Lot No.");
                            end;
                            ItemJnlLine_lRec.Validate("Location Code", ItemLedgEntry_lRec."Location Code");
                            //ItemJnlLine_lRec.VALIDATE("Bin Code",);
                            ItemJnlLine_lRec.Validate("Order Line No.", ItemLedgEntry_lRec."Order Line No.");
                            ItemJnlLine_lRec.Validate("Prod. Order Comp. Line No.", ItemLedgEntry_lRec."Prod. Order Comp. Line No.");
                            if CheckITemTrackingItem_lFnc(ItemLedgEntry_lRec."Item No.") then
                                ItemJnlLine_lRec.Validate("Applies-from Entry", ItemLedgEntry_lRec."Entry No.");
                            ItemJnlLine_lRec."Cons. Return Ref. No." := ItemLedgEntry_lRec."Document No.";

                            if DefaultDimension_lRec.Get(27, ItemJnlLine_lRec."Item No.", 'PRODUCT') then begin
                                Clear(DimensionChangesMgt_lCdu);
                                DimensionChangesMgt_lCdu.FillDimSetEntry_gFnc(ItemJnlLine_lRec."Dimension Set ID", TmpDimensionSetEntry_lRecTmp);
                                DimensionChangesMgt_lCdu.UpdateDimSetEntry_gFnc(TmpDimensionSetEntry_lRecTmp, 'PRODUCT', DefaultDimension_lRec."Dimension Value Code");
                                ItemJnlLine_lRec."Dimension Set ID" := DimensionChangesMgt_lCdu.GetDimensionSetID_gFnc(TmpDimensionSetEntry_lRecTmp);
                                DimensionChangesMgt_lCdu.UpdGlobalDimFromSetID_gFnc(ItemJnlLine_lRec."Dimension Set ID", ItemJnlLine_lRec."Shortcut Dimension 1 Code", ItemJnlLine_lRec."Shortcut Dimension 2 Code");
                            end;

                            ItemJnlLine_lRec.Insert;
                        until (ItemLedgEntry_lRec.Next = 0) or (RemQtyForNegativeConsumption_lDec = 0);
                    end;
                end;
            until ProdOrderChangeNoteLine_lRec.Next = 0;
        end;
        //CreateNegativeConsumptionEntry-NE 12-09-17
    end;


    procedure CheckITemTrackingItem_lFnc(ItemCode_iCod: Code[20]): Boolean
    var
        Item_lRec: Record Item;
    begin
        //CreateNegativeConsumptionEntry-NS 12-09-17
        if ItemCode_iCod = '' then
            exit(true);

        Item_lRec.Get(ItemCode_iCod);
        if Item_lRec."Item Tracking Code" = '' then
            exit(true)
        else
            exit(false);
        //CreateNegativeConsumptionEntry-NE 12-09-17
    end;

    local procedure GetLastLineNo_lFnc(TemplateName_iCod: Code[20]; BatchName_iCod: Code[20]): Integer
    var
        IJL_lRec: Record "Item Journal Line";
    begin
        IJL_lRec.Reset;
        IJL_lRec.SetRange("Journal Template Name", TemplateName_iCod);
        IJL_lRec.SetRange("Journal Batch Name", BatchName_iCod);
        if IJL_lRec.FindLast then
            exit(IJL_lRec."Line No." + 10000)
        else
            exit(10000);
    end;


    procedure DeleteNegativeConsumptionEntry_gFnc(ProdOrderChangeNoteHdr_iRec: Record "Prod. Order Change Note Header")
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
        ItemJnlLine_lRec: Record "Item Journal Line";
        ItemLedgEntry_lRec: Record "Item Ledger Entry";
        ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        QtyForNegativeConsumption_lDec: Decimal;
        RemQtyForNegativeConsumption_lDec: Decimal;
        ILERemQty_lDec: Decimal;
    begin
        //CreateNegativeConsumptionEntry-NS 12-09-17
        Clear(ManufacturingSetup_lRec);
        ManufacturingSetup_lRec.Get;
        ManufacturingSetup_lRec.TestField("Item Templete - Con. Neg. Adj.");
        ManufacturingSetup_lRec.TestField("Item Batch - Con. Neg. Adj.");

        ItemJnlLine_lRec.Reset;
        ItemJnlLine_lRec.SetRange("Journal Template Name", ManufacturingSetup_lRec."Item Templete - Con. Neg. Adj.");
        ItemJnlLine_lRec.SetRange("Journal Batch Name", ManufacturingSetup_lRec."Item Batch - Con. Neg. Adj.");
        ItemJnlLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_iRec."No.");
        if ItemJnlLine_lRec.IsEmpty then
            Error('There is nothing to delete');

        ItemJnlLine_lRec.DeleteAll(true);
        Message('Reverse Consumption Lines Deleted Successfully');
    end;

    local procedure CheckToPrincipleInputQtyPerSum_gFnc(var ProdOrderChangeNoteHdr_vRec: Record "Prod. Order Change Note Header")
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
        ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        QtyPerSum_lDec: Decimal;
        ProductionOrder_lRec: Record "Production Order";
    begin
        //ProdOrderChangeNote-NS
        ManufacturingSetup_lRec.Get;
        if not ManufacturingSetup_lRec."Match Tot Qty. with Princple" then
            exit;

        QtyPerSum_lDec := 0;
        ProdOrderChangeNoteLine_lRec.Reset;
        ProdOrderChangeNoteLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_vRec."No.");
        ProdOrderChangeNoteLine_lRec.SetFilter(Action, '%1|%2|%3', ProdOrderChangeNoteLine_lRec.Action::" ", ProdOrderChangeNoteLine_lRec.Action::Modify, ProdOrderChangeNoteLine_lRec.Action::Add);
        ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
        if ProdOrderChangeNoteLine_lRec.FindSet then begin
            repeat
                if ProdOrderChangeNoteLine_lRec.Action in [ProdOrderChangeNoteLine_lRec.Action::Modify, ProdOrderChangeNoteLine_lRec.Action::Add] then
                    QtyPerSum_lDec += ProdOrderChangeNoteLine_lRec."New Expected Quantity"
                else
                    QtyPerSum_lDec += ProdOrderChangeNoteLine_lRec."Expected Quantity";
            until ProdOrderChangeNoteLine_lRec.Next = 0;
        end;

        if QtyPerSum_lDec <> 0 then begin
            ProductionOrder_lRec.Reset;
            ProductionOrder_lRec.SetRange("No.", ProdOrderChangeNoteHdr_vRec."Prod. Order No.");
            ProductionOrder_lRec.FindFirst;
            if QtyPerSum_lDec <> ProductionOrder_lRec.Quantity then
                Error('The Sum of Expected Quantity (%1) for all Lines must be equal to Quantity (%2) of Production Order.', QtyPerSum_lDec, ProductionOrder_lRec.Quantity);
        end;
        //ProdOrderChangeNote-NE
    end;

    local procedure CheckQtyPerSum_gFnc(var ProdOrderChangeNoteHdr_vRec: Record "Prod. Order Change Note Header")
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
        ProdOrderChangeNoteLine_lRec: Record "Prod. Order Change Note Line";
        QtyPerSum_lDec: Decimal;
    begin
        //ProdOrderChangeNote-NS
        ManufacturingSetup_lRec.Get;
        if not ManufacturingSetup_lRec."Check Qty. per Sum equals 1" then
            exit;

        QtyPerSum_lDec := 0;
        ProdOrderChangeNoteLine_lRec.Reset;
        ProdOrderChangeNoteLine_lRec.SetRange("Document No.", ProdOrderChangeNoteHdr_vRec."No.");
        ProdOrderChangeNoteLine_lRec.SetFilter(Action, '%1|%2|%3', ProdOrderChangeNoteLine_lRec.Action::" ", ProdOrderChangeNoteLine_lRec.Action::Modify, ProdOrderChangeNoteLine_lRec.Action::Add);
        ProdOrderChangeNoteLine_lRec.SetRange("Principal Input", true);
        if ProdOrderChangeNoteLine_lRec.FindSet then begin
            repeat
                //    IF ProdOrderChangeNoteLine_lRec.Action IN [ProdOrderChangeNoteLine_lRec.Action::Modify,ProdOrderChangeNoteLine_lRec.Action::Add] THEN
                //      QtyPerSum_lDec += ProdOrderChangeNoteLine_lRec."New Quantity Per"
                //    ELSE
                //      QtyPerSum_lDec  += ProdOrderChangeNoteLine_lRec."Quantity Per";

                QtyPerSum_lDec += ProdOrderChangeNoteLine_lRec."Final Qty. Per";
            until ProdOrderChangeNoteLine_lRec.Next = 0;
        end;

        if QtyPerSum_lDec <> 0 then begin
            if ROUND(QtyPerSum_lDec, 0.001) <> 1 then
                Error('The Sum of Quantity Per for all Lines must be equal to 1.Current Value: %1', QtyPerSum_lDec);
        end;
        //ProdOrderChangeNote-NE
    end;

    local procedure "---------------Email-----------"()
    begin
    end;


    procedure NewSendEmail_gFnc(UserApprovalEntry_iRec: Record "Adv_User Approval Entry")
    var
        EmailTemplateSetup_lRec: Record "Email Template Setup";
        BodyMessage_lTxt: Text[250];
        BodyMessage1_lTxt: Text[250];
        BodyMessage2_lTxt: Text[250];
        BodyMessage3_lTxt: Text[250];
        BodyMessage4_lTxt: Text[250];
        BodyMessage5_lTxt: Text[250];
        BodyMessage6_lTxt: Text[250];
        BodyMessage7_lTxt: Text[250];
        PurchIndentHeader_lRec: Record "Purchase Indent Header";
        Subject_lTxt: Text[100];
        Sender_lTxt: Text[50];
        Tittle_lTxt: Text[50];
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        UserSetup_lRec: Record "User Setup";
        ApproverName_gTxt: Text;
        Users_lRec: Record User;
        UserApprovalLevel_lRec: Record "Adv_User Approver Sequence";
        RequestorUserSetup_lRec: Record "User Setup";
        Serverfile_lTxt: Text;
        FileExtension_lTxt: Text[80];
        FileMgt_lCdu: Codeunit "File Management";
        FADisposal_lTxt: Text;
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        EmailTemplates_lRec: Record "Email Template";
        URL_lTxt: Text;
        ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
        PageManagement: Codeunit "Page Management";
    begin

        EmailTemplateSetup_lRec.Get;
        EmailTemplateSetup_lRec.TestField(EmailTemplateSetup_lRec."PCN Send Email");
        EmailTemplates_lRec.Get(EmailTemplateSetup_lRec."PCN Send Email");

        //ProdOrderChangeNoteHdr_lRec.SETRANGE("No.",UserApprovalEntry_iRec."Prod. Order Change Note No.");
        //ProdOrderChangeNoteHdr_lRec.SETRANGE("Prod. Order Status",UserApprovalEntry_iRec."Prod. Order Status");
        //ProdOrderChangeNoteHdr_lRec.SETRANGE("Prod. Order No.",UserApprovalEntry_iRec."Prod. Order No.");
        //ProdOrderChangeNoteHdr_lRec.SETRANGE("Prod. Order Line No.",UserApprovalEntry_iRec."Prod. Order Line No.");
        //ProdOrderChangeNoteHdr_lRec.FINDFIRST;
        //URL_lTxt := STRSUBSTNO('<b>Web Client URL:</b> %1',
        //                          STRSUBSTNO(CustomUrlAndAnchorTxt,GETURL(CLIENTTYPE::Web,COMPANYNAME,OBJECTTYPE::Page,PAGE::"Prod. Order Change Note Card",ProdOrderChangeNoteHdr_lRec,TRUE)));

        URL_lTxt := StrSubstNo('<b>Web Client URL:</b> %1',
                                  StrSubstNo(CustomUrlAndAnchorTxt, GetUrl(Clienttype::Web, COMPANYNAME, Objecttype::Page, Page::"Prod. Order Change App. Entry", UserApprovalEntry_iRec, true)));
        EmailTemplates_lRec.TestField(Subject);

        BodyMessage_lTxt := EmailTemplates_lRec."Body 1";
        BodyMessage1_lTxt := EmailTemplates_lRec."Body 2";
        BodyMessage2_lTxt := EmailTemplates_lRec."Body 3";
        BodyMessage3_lTxt := EmailTemplates_lRec."Body 4";
        BodyMessage4_lTxt := EmailTemplates_lRec."Body 5";
        BodyMessage5_lTxt := EmailTemplates_lRec."Body 6";
        BodyMessage6_lTxt := EmailTemplates_lRec."Body 7";
        BodyMessage7_lTxt := EmailTemplates_lRec."Body 8";

        Clear(EmailMessage);

        Clear(UserSetup_lRec);
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Approver ID");
        if UserSetup_lRec."E-Mail" = '' then
            exit;

        receipent.Add(UserSetup_lRec."E-Mail");
        Subject_lTxt := StrSubstNo('%1 No:%2', EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Prod. Order Change Note No.");
        // Subject_lTxt := StrSubstNo(EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Document No.");
        //Tittle_lTxt := EmailTemplates_lRec.Title;


        UserApprovalLevel_lRec.Reset;
        UserApprovalLevel_lRec.SetRange("Approval Source", "Approval Source"::"Production Change Note");
        UserApprovalLevel_lRec.SetRange("Source UserID", UserApprovalEntry_iRec."Requester ID");
        UserApprovalLevel_lRec.SetRange(Sequence, UserApprovalEntry_iRec."Approval level" - 1);
        if UserApprovalLevel_lRec.FindFirst then begin
            //I-A004_B-5000131-01-NS
            Clear(UserSetup_lRec);
            if UserSetup_lRec.Get(UserApprovalLevel_lRec."Approver UserID") then
                IF UserSetup_lRec."E-Mail" <> '' Then
                    EmailTemplates_lRec.GetListOfEmail_gFnc(UserSetup_lRec."E-Mail", CC);
            //CC.Add(UserSetup_lRec."E-Mail");
            //I-A004_B-5000131-01-NE
        end;

        //CP-NS
        Clear(RequestorUserSetup_lRec);
        if RequestorUserSetup_lRec.Get(UserApprovalEntry_iRec."Requester ID") then begin
            RequestorUserSetup_lRec.TestField("E-Mail");
            EmailTemplates_lRec.GetListOfEmail_gFnc(RequestorUserSetup_lRec."E-Mail", CC);
            //CC.Add(RequestorUserSetup_lRec."E-Mail");
        end;

        if EmailTemplates_lRec."Email CC" <> '' then begin
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email CC", CC);
            //CC.Add(EmailTemplates_lRec."Email CC");
        end;
        //CP-NE


        if EmailTemplates_lRec."Email BCC" <> '' then
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email BCC", BCC);
        //BCC.Add(EmailTemplates_lRec."Email BCC");

        //EmailMessage.CreateMessage(Tittle_lTxt, Sender_lTxt, Recipients_lTxt, Subject_lTxt, ' ', true);
        EmailMessage.Create(receipent, Subject_lTxt, '', true, CC, BCC);

        EmailMessage.AppendToBody(BodyMessage_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(StrSubstNo('%1 is %2', BodyMessage1_lTxt, UserApprovalEntry_iRec."Prod. Order Change Note No."));
        //EmailMessage.AppendToBody(StrSubstNo(BodyMessage1_lTxt, UserApprovalEntry_iRec."Document No."));
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage2_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage3_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage4_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage5_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage6_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage7_lTxt);
        EmailMessage.AppendToBody(URL_lTxt);
        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
    end;


    procedure NewApprovedSendEmail_gFnc(UserApprovalEntry_iRec: Record "Adv_User Approval Entry")
    var
        EmailTemplateSetup_lRec: Record "Email Template Setup";
        BodyMessage_lTxt: Text[250];
        BodyMessage1_lTxt: Text[250];
        BodyMessage2_lTxt: Text[250];
        BodyMessage3_lTxt: Text[250];
        BodyMessage4_lTxt: Text[250];
        BodyMessage5_lTxt: Text[250];
        BodyMessage6_lTxt: Text[250];
        BodyMessage7_lTxt: Text[250];
        PurchIndentHeader_lRec: Record "Purchase Indent Header";
        Subject_lTxt: Text[100];
        Sender_lTxt: Text[50];
        Tittle_lTxt: Text[50];
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        UserSetup_lRec: Record "User Setup";
        ApproverName_gTxt: Text;
        Users_lRec: Record User;
        UserApprovalLevel_lRec: Record "Adv_User Approver Sequence";
        RequestorUserSetup_lRec: Record "User Setup";
        Serverfile_lTxt: Text;
        FileExtension_lTxt: Text[80];
        FileMgt_lCdu: Codeunit "File Management";
        FADisposal_lTxt: Text;
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        Text002_gCtx: label 'FA Disposal No.: %1 has been approved.';
        EmailTemplates_lRec: Record "Email Template";
    begin

        //ApprovedMail-NS
        EmailTemplateSetup_lRec.Get;
        EmailTemplateSetup_lRec.TestField(EmailTemplateSetup_lRec."PCN Approve Email");
        EmailTemplates_lRec.Get(EmailTemplateSetup_lRec."PCN Approve Email");

        EmailTemplates_lRec.TestField(Subject);

        BodyMessage_lTxt := EmailTemplates_lRec."Body 1";
        BodyMessage1_lTxt := EmailTemplates_lRec."Body 2";
        BodyMessage2_lTxt := EmailTemplates_lRec."Body 3";
        BodyMessage3_lTxt := EmailTemplates_lRec."Body 4";
        BodyMessage4_lTxt := EmailTemplates_lRec."Body 5";
        BodyMessage5_lTxt := EmailTemplates_lRec."Body 6";
        BodyMessage6_lTxt := EmailTemplates_lRec."Body 7";
        BodyMessage7_lTxt := EmailTemplates_lRec."Body 8";

        Clear(EmailMessage);

        Clear(UserSetup_lRec);
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Requester ID");

        if UserSetup_lRec."E-Mail" = '' then
            exit;

        receipent.Add(UserSetup_lRec."E-Mail");
        Subject_lTxt := StrSubstNo('%1 No:%2', EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Prod. Order Change Note No.");
        //Subject_lTxt := StrSubstNo(EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Document No.");
        //Tittle_lTxt := EmailTemplates_lRec.Title;



        Clear(UserSetup_lRec);
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Approver ID");
        IF UserSetup_lRec."E-Mail" <> '' then
            //CC.Add(UserSetup_lRec."E-Mail");
            EmailTemplates_lRec.GetListOfEmail_gFnc(UserSetup_lRec."E-Mail", CC);

        //CP-NS
        if EmailTemplates_lRec."Email CC" <> '' then begin
            //CC.Add(EmailTemplates_lRec."Email CC");
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email CC", CC);
        end;
        //CP-NE



        if EmailTemplates_lRec."Email BCC" <> '' then
            // BCC.Add(EmailTemplates_lRec."Email BCC");
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email BCC", BCC);


        //EmailMessage.CreateMessage(Tittle_lTxt, Sender_lTxt, Recipients_lTxt, Subject_lTxt, ' ', true);
        EmailMessage.Create(receipent, Subject_lTxt, '', true, CC, BCC);

        EmailMessage.AppendToBody(BodyMessage_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(StrSubstNo('%1 is %2', BodyMessage1_lTxt, UserApprovalEntry_iRec."Prod. Order Change Note No."));
        //EmailMessage.AppendToBody(STRSUBSTNO(Text002_gCtx,UserApprovalEntry_iRec."Document No."));
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage2_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage3_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage4_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage5_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage6_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage7_lTxt);

        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
        //ApprovedMail-NE
    end;


    procedure NewRejectedSendEmail_gFnc(UserApprovalEntry_iRec: Record "Adv_User Approval Entry")
    var
        EmailTemplateSetup_lRec: Record "Email Template Setup";
        BodyMessage_lTxt: Text[250];
        BodyMessage1_lTxt: Text[250];
        BodyMessage2_lTxt: Text[250];
        BodyMessage3_lTxt: Text[250];
        BodyMessage4_lTxt: Text[250];
        BodyMessage5_lTxt: Text[250];
        BodyMessage6_lTxt: Text[250];
        BodyMessage7_lTxt: Text[250];
        PurchIndentHeader_lRec: Record "Purchase Indent Header";
        Subject_lTxt: Text[100];
        Sender_lTxt: Text[50];
        Tittle_lTxt: Text[50];
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        UserSetup_lRec: Record "User Setup";
        ApproverName_gTxt: Text;
        Users_lRec: Record User;
        UserApprovalLevel_lRec: Record "Adv_User Approver Sequence";
        RequestorUserSetup_lRec: Record "User Setup";
        Serverfile_lTxt: Text;
        FileExtension_lTxt: Text[80];
        FileMgt_lCdu: Codeunit "File Management";
        FADisposal_lTxt: Text;
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        Text002_gCtx: label 'FA Disposal No.: %1 has been Rejected.';
        EmailTemplates_lRec: Record "Email Template";
    begin

        //RejectionMail-NS
        EmailTemplateSetup_lRec.Get;
        EmailTemplateSetup_lRec.TestField(EmailTemplateSetup_lRec."PCN Reject Email");
        EmailTemplates_lRec.Get(EmailTemplateSetup_lRec."PCN Reject Email");

        EmailTemplates_lRec.TestField(Subject);

        BodyMessage_lTxt := EmailTemplates_lRec."Body 1";
        BodyMessage1_lTxt := EmailTemplates_lRec."Body 2";
        BodyMessage2_lTxt := EmailTemplates_lRec."Body 3";
        BodyMessage3_lTxt := EmailTemplates_lRec."Body 4";
        BodyMessage4_lTxt := EmailTemplates_lRec."Body 5";
        BodyMessage5_lTxt := EmailTemplates_lRec."Body 6";
        BodyMessage6_lTxt := EmailTemplates_lRec."Body 7";
        BodyMessage7_lTxt := EmailTemplates_lRec."Body 8";

        Clear(EmailMessage);

        Clear(UserSetup_lRec);
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Requester ID");
        IF UserSetup_lRec."E-Mail" = '' then
            Exit;

        receipent.Add(UserSetup_lRec."E-Mail");
        Subject_lTxt := StrSubstNo('%1 No:%2', EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Prod. Order Change Note No.");
        //Subject_lTxt := StrSubstNo(EmailTemplates_lRec.Subject, UserApprovalEntry_iRec."Document No.");
        //Tittle_lTxt := EmailTemplates_lRec.Title;



        Clear(UserSetup_lRec);
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Approver ID");
        IF UserSetup_lRec."E-Mail" <> '' then
            //CC.Add(UserSetup_lRec."E-Mail");
            EmailTemplates_lRec.GetListOfEmail_gFnc(UserSetup_lRec."E-Mail", CC);

        //CP-NS
        if EmailTemplates_lRec."Email CC" <> '' then begin
            //CC.Add(EmailTemplates_lRec."Email CC");
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email CC", CC);
        end;
        //CP-NE


        if EmailTemplates_lRec."Email BCC" <> '' then
            // BCC.Add(EmailTemplates_lRec."Email BCC");
            EmailTemplates_lRec.GetListOfEmail_gFnc(EmailTemplates_lRec."Email BCC", BCC);


        //EmailMessage.CreateMessage(Tittle_lTxt, Sender_lTxt, Recipients_lTxt, Subject_lTxt, ' ', true);
        EmailMessage.Create(receipent, Subject_lTxt, '', true, CC, BCC);

        EmailMessage.AppendToBody(BodyMessage_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(StrSubstNo('%1 is %2', BodyMessage1_lTxt, UserApprovalEntry_iRec."Prod. Order Change Note No."));
        //EmailMessage.AppendToBody(STRSUBSTNO(Text002_gCtx,UserApprovalEntry_iRec."Document No."));
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage2_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage3_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage4_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage5_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage6_lTxt);
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody('<BR/>');
        EmailMessage.AppendToBody(BodyMessage7_lTxt);

        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
        //RejectionMail-NE
    end;
}

